module Shares
  def self.shares k
    o, s, r = 0, 0, SHARES[k].to_i || 100
    Redis::SortedSet.new("shares:#{k}").members(with_scores: true).to_h.each_pair {|k,v| if v > 0; o += 1; end; s += v; r -= v; }
    return {owners: o, held: s, max: SHARES[k].to_i, remaining: r}
  end
  def self.cost k
    o, s = 0, 0
    Redis::SortedSet.new("shares:#{k}").members(with_scores: true).to_h.each_pair {|k,v| o += 1; s += v }
    return ((2 ** o) + (2 ** "#{s.to_i}".length)) 
  end
  def self.by(k)
    Redis::SortedSet.new("shares:#{k}")
  end
  def self.mint k, u, *n
    if n[0]
      nn = n[0].to_i
    else
      nn = 1
    end
    Redis::SortedSet.new("shares:#{k}").incr(u, nn)
  end
  def self.burn k, u, *n
    if n[0]
      nn = n[0].to_i
    else
      nn = 1
    end
    Redis::SortedSet.new("shares:#{k}").decr(u, nn)
  end
end

module Bank
  ##              ##
  #                #
  # banking system #
  #                #
  ##              ##
  #
  # balance: U.new(@id).coins.value
  # credit: Bank.wallet[@id]
  #
  # - [balance] is the active amount of credits in a user's account.
  #   credits can be used to pay for industry to industry services
  #   and other sponsored events.
  #
  # - [credit] is the amount of credit purchased or earned and inactivated by
  #   a user.  A user may stash their credits and attach them to
  #   an identifier by texting a dollar amount to the number.
  #   The returned id number may be redeemed by texting the id number
  #   to the number.  building credit allows you to qualify for brand
  #   sponsorship.
  #
  def self.mint *c
    if c[0]
      cc = c[0]
    else
      cc = 1
    end
    U.new('BANK').coins.increment cc
  end
  def self.burn *c
    if c[0]
      cc = c[0]
    else
      cc = 1
    end
    U.new('BANK').coins.decrement cc
  end
  def self.supply
    U.new('BANK').coins.value
  end
  def self.wallet
    Redis::SortedSet.new("wallet")
  end
  def self.vault a
    i = []; VAULT_SIZE.times { i << rand(16).to_s(16) }
    Bank.vaults[i.join('')] = a
    return i.join('')
  end
  def self.vaults
    Redis::SortedSet.new('VAULT')
  end
  ##
  # save coins for later
  def self.stash h={}
    cns = (EXCHANGE[h[:host]].to_i || 1 * h[:amt]).to_i
    U.new(h[:from]).coins.decr(cns)
    U.new('BANK').wallet.incr('VAULT', cns)
    Bank.wallet.incr(h[:from], cns)
    U.new(h[:from]).log << %[STASH #{Time.now.utc} #{JSON.generate(h)}]
    return {
      id: Bank.vault(cns), 
      amt: cns,
      balance: U.new(h[:from]).coins.value,
      credit: Bank.wallet[h[:from]]
    }
  end
  
  ##
  # recover stashed coins 
  def self.recover h={}
    a = Bank.vaults[h[:id]].to_i
    Bank.vaults.delete(h[:id])
    U.new('BANK').wallet.decr('VAULT', a)
    U.new(h[:to]).coins.incr(a)
    Bank.wallet.decr(h[:to], a)
    U.new(h[:to]).log << %[RECOVER #{Time.now.utc} #{JSON.generate(h)}]
    return {
      id: h[:id],
      amt: a,
      balance: U.new(h[:to]).coins.value,
      credit: Bank.wallet[h[:to]]
    }
  end
  
  def self.xfer h={}
    b = U.new('BANK')
    f = U.new(h[:from] || 'BANK')
    f.wallet.decr(h[:type] || :gp, h[:amt].to_i)
    f.coins.decr(h[:amt].to_i)
    t = U.new(h[:to] || 'BANK')
    if h.has_key? :in
      d = h[:in]
    elsif h.has_key? :at
      d = timer(h[:at])
    else
      d = 0
    end
    if h[:fee]
      fee = ("#{d}".length * h[:fee].to_i).to_i
      f.coins.decr(fee)
      b.coins.incr(fee)
    end
    CRON.at(Time.now + d) do
      t.wallet.incr(h[:type] || :gp, h[:amt].to_i)
      t.coins.incr(h[:amt].to_i)
    end
  end
end

class Blockchain
  attr_accessor :chain, :current_transactions
  def initialize pfx
    @action = Redis::SortedSet.new('ACTION:' + pfx)
    @finger = Redis::SortedSet.new('FINGER:' + pfx)
    @chain = Redis::List.new('CHAIN:' + pfx, marshal: true)
    @a = Redis::HashKey.new('A:' + pfx)
    @l = Redis::HashKey.new('L:' + pfx)
    @current_transactions = []
    new_block(1, 100)
  end
  
  # Creates a new Block and adds it to the chain
  def new_block(proof, previous_hash = nil)
    block = {
      index: @chain.length + 1,
      epoch: Time.now.utc.to_f,
      transactions:  @current_transactions,
      cost:          @current_transactions.length - 1,
      proof:         proof,
      previous_hash: previous_hash || Blockchain.hash(@chain.last)
    }
    @current_transactions = []; @chain << block; block
  end
  
  def block_cost
    @current_transactions.length + 1
  end
  
  # Adds a new transaction to the list of transactions
  def new_transaction(sender, recipient, amount, fing, act)
    Redis.new.publish('Blockchain.new_transaction', "#{sender} #{recipient} #{amount} #{fing} #{act}")
    @action.incr("#{recipient}:#{act}")
    @finger.incr("#{recipient}##{fing.join(':')}")
    user(sender).coins.decrement(amount)
    user(recipient).coins.increment(amount)
    h = {
      epoch: Time.now.utc.to_f,
      sender: sender,
      recipient: recipient,
      amount: amount,
      fingerprint: fing,
      act: act
    }
    @current_transactions << h
    last_block[:index] + 1
    return h
  end
  
  def acts
    @action.members(with_scores: true).to_h
  end
  def fingers
    @finger.members(with_scores: true).to_h
  end
  
  def proof_of_work(last_proof); proof = 0; while !valid_proof?(last_proof, proof); proof += 1; end; proof; end
  def last_block; @chain.values.last; end
  def hash(block); Digest::MD5.hexdigest(block.sort.to_h.to_json.encode); end
  def uuid; SecureRandom.uuid.gsub("-", ""); end
  
  def [] a
    if !@l.has_key? a
      u = uuid
      @a[u] = a
      @l[a] = u
    end
    return @l[a]
  end
  
  private
  
  # Validates the Proof: Does hash(last_proof, proof) contain 4 leading zeroes?
  def valid_proof?(last_proof, proof)
    Digest::MD5.hexdigest("#{last_proof}#{proof}".encode)[0..3] == "0000"
  end
end
