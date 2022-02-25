# encoding: utf-8
# network
ID_SIZE = 16
VAULT_SIZE = 8


FEES = { xfer: 1 }

BDG = [
  :nomad,
  :pedicab,
  :food,
  :bike,
  :grill,
  :pathfinder,
  :kids,
  :meals,
  :pizza,
  :bar,
  :asian,
  :coffee,
  :influence,
  :referral,
  :directions,
  :adventure,
  :radio,
  :dispatch,
  :farmer,
  :cannabis,
  :medic,
  :guide,
  :fire,
  :calm,
  :developer,
  :party,
  :event,
  :nightlife,
  :hauling,
  :bus,
  :race,
  :building,
  :fixing,
  :emergency,
  :bug,
  :network,
  :comms
]


BADGES = {
  nomad: 'backpack',
  pedicab: 'bike_scooter',
  food: 'fastfood',
  bike: 'directions_bike',
  grill: 'outdoor_grill',
  pathfinder: 'highlight',
  kids: 'child_friendly',
  meals: 'restaurant',
  pizza: 'local_pizza',
  bar: 'local_bar',
  asian: 'set_meal',
  coffee: 'local_cafe',
  influence: 'campaign',
  referral: 'loyalty',
  directions: 'directions',
  adventure: 'explore',
  radio: 'radio',
  dispatch: 'support_agent',
  farmer: 'agriculture',
  cannabis: 'smoking_rooms',
  medic: 'medical_services',
  guide: 'tour',
  fire: 'local_fire_department',
  calm: 'self_improvement',
  developer: 'memory',
  party: 'celebration',
  event: 'festival',
  nightlife: 'nightlife',
  hauling: 'local_shipping',
  bus: 'airport_shuttle',
  race: 'sports_score',
  building: 'carpenter',
  fixing: 'construction',
  emergency: 'fire_extinguisher',
  bug: 'pest_control',
  network: 'router',
  comms: 'leak_add'
}

DEPS = {
  nomad: [ :bike, :dispatch, :pathfinder, :medic ],
  pedicab: [],
  food: [ :pizza, :grill, :asian, :meals, :coffee ],
  bike: [],
  grill: [],
  pathfinder: [ :directions ],
  kids: [],
  meals: [],
  pizza: [],
  bar: [],
  asian: [],
  coffee: [],
  influence: [ :fire ],
  referral: [],
  directions: [],
  adventure: [ :pedicab, :guide, :radio, :fire  ],
  radio: [],
  dispatch: [ :radio ],
  farmer: [],
  cannabis: [ :farmer ],
  medic: [],
  guide: [ :directions ],
  fire: [ :referral ],
  calm: [ :emergency ],
  developer: [ :comms ],
  party: [ :referral ],
  event: [ :party ],
  nightlife: [ :party ],
  hauling: [],
  bus: [ :hauling ],
  race: [ :pedicab ],
  building: [ :fixing ],
  fixing: [],
  emergency: [ :fixing, :medic ],
  bug: [],
  network: [ :bug ],
  comms: [ :radio, :network ]
}

DESCRIPTIONS = {
  nomad: 'able to operate autonomously.',
  pedicab: 'able to operate a pedicab.',
  food: 'knowledgable on the subject of food,',
  bike: 'able to operate a pedicab.',
  grill: 'knowlegable on the subject of grilled meat,',
  pathfinder: 'able to manage multiple transportation vectors.',
  kids: 'child friendly.',
  meals: 'knowlegable on the subject of sit down meals.',
  pizza: 'knowlegable on the subject of pizza,',
  bar: 'knowlegable on the subject of local bars,',
  asian: 'knowlegable on the subject of asian food,',
  coffee: 'knowlegable on the subject of local coffee,',
  influence: 'knowlegable on the subject of ultra-exclusive local events.',
  referral: 'knowlegable on the subject of local events.',
  directions: 'able to find things.',
  adventure: 'qualified to conduct adventures.',
  radio: 'qualified to use a radio.',
  dispatch: 'managing network radio operatons.',
  farmer: 'knowlegable on the subject of growing things,',
  cannabis: 'knowlegable on the subject of cannabis,',
  medic: 'able to help you.',
  guide: 'able to show you around.',
  fire: 'knowlegable on the subject of exclusive local events.',
  calm: 'a field network operator.',
  developer: 'helping keep the network working.',
  party: 'special event coordination.',
  event: 'large scale event coordination.',
  nightlife: 'nightlife specialist.',
  hauling: 'is experienced in shipping.',
  bus: 'long distance transportation.',
  race: 'a pedicab racer.',
  building: 'good at building things.',
  fixing: 'good at fixing things.',
  emergency: 'coordinating disasters.',
  bug: 'finding software problems.',
  network: 'fixing network problems',
    comms: 'developing network solutions.'
}

ICONS = {
  call: 'call',
  sms: 'message',
  tip: 'cash',
  venmo: 'venmo',
  facebook: 'facebook',
  instagram: 'instagram',
  snapchat: 'snapchat'
}
require 'rqrcode'
require 'webpush'
require 'paho-mqtt'
require 'redis-objects'
require 'sinatra/base'
require 'sinatra-websocket'
require 'thin'
require 'json'
require 'slop'
require 'pry'
require 'rufus-scheduler'
require 'twilio-ruby'
require 'redcarpet'
require 'cerebrum'
require 'cryptology'
require 'sentimental'
require 'digest/md5'
require 'securerandom'
require 'browser'

load "bin/colorize.rb"


CRON = Rufus::Scheduler.new
DOMAINS = Redis::Set.new("DOMAINS")
VOTES = Redis::Set.new("VOTES")
ZONES = Redis::Set.new("ZONES")
TITLES = Redis::Set.new("TITLES")
CHA = Redis::HashKey.new('CHA')
IDS = Redis::HashKey.new('IDS')
JOBS = Redis::HashKey.new('JOBS')
DEVS = Redis::HashKey.new('DEVS')
DB = Redis::HashKey.new('DB')
BOOK = Redis::HashKey.new('BOOK')
PAGERS = Redis::HashKey.new('PAGERS')
LOOK = Redis::HashKey.new('LOOK')
LANDING = Redis::HashKey.new('LANDING')
LOCKED = Redis::HashKey.new('LOCKED')
CODE = Redis::HashKey.new('CODE')
TREE = Redis::HashKey.new('TREE')
LOCS = Redis::Set.new("LOCS")
ADVENTURES = Redis::Set.new("ADVENTURES")
CAMS = Redis::HashKey.new("CAMS")
QRI = Redis::HashKey.new("QRI")
QRO = Redis::HashKey.new("QRO")
LOGINS = Redis::HashKey.new("LOGINS")
QUICK = Redis::HashKey.new("QUICK")
MUMBLE = Redis::HashKey.new('MUMBLE')
PHONES = Redis::HashKey.new("PHONES")
ADMINS = Redis::HashKey.new("ADMINS")
OWNERSHIP = Redis::HashKey.new("OWNERSHIP")
EXCHANGE = Redis::HashKey.new("EXCHANGE")
SHARES = Redis::HashKey.new("SHARES")
TOS = Redis::HashKey.new('TOS')
FRANCHISE = Redis::HashKey.new("FRANCHISE")
PROCUREMENT = Redis::HashKey.new('PROCUREMENT')
FULFILLMENT = Redis::HashKey.new('FULFILLMENT')
XFER = Redis::HashKey.new("XFER")

BRAIN = Cerebrum.new

SENTIMENT = Sentimental.new
SENTIMENT.load_defaults
SENTIMENT.threshold = 0.1

def sentiment s
{ sentment:  SENTIMENT.sentiment(s), score: SENTIMENT.score(s) }  
end




def phone_tree phone, h={}
  if h.keys.length > 0
    TREE[phone] = JSON.generate(h)
  end
end


module Cypher
  def self.encrypt key, data
    return Cryptology.encrypt(data: data, key: key, cipher: 'CHACHA20-POLY1305')['data']
  end
  def self.decrypt key, data
    if Cryptology.decryptable?(data: data, key: key, cipher: 'CHACHA20-POLY1305')
      plain = Cryptology.decrypt(data: data, key: key, cipher: 'CHACHA20-POLY1305')
    else
      plain = false
    end
    return plain
  end
end

def user u
  U.new(u)
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

BLOCKCHAIN = Blockchain.new('/')

class Broker
  
  def initialize h={}
    @h = h
    @c = PahoMqtt::Client.new
    @blocks = {}
    @c.on_message { |message|
      if @blocks.has_key? message.topic
        @blocks[message.topic].call(message.topic, JSON.parse(message.payload || "{}"))
      end
    }
    @c.connect(h[:host] || 'localhost', h[:port] || 1883)
  end
  def bridge l, &b
    @blocks[l] = b
    sub(topic: l)
  end
  def sub h={}
    @c.subscribe([h[:topic] || '#', h[:qos] || 2])
  end
  def pub h={}
    @c.publish(h[:topic], h[:payload], h[:retain] || false, h[:qos] || 1)
  end
  def client
    @c
  end
end


def code w, j={}
  CODE[w] = JSON.generate(j)
end

def timer h={}
  t = 0
  t += (h[:years].to_i * (365 * (24 * (60 * 60))))
  t += (h[:months].to_i * (30 * (24 * (60 * 60))))
  t += (h[:weeks].to_i * (7 * (24 * (60 * 60))))
  t += (h[:days].to_i * (24 * (60 * 60)))
  t += (h[:hours].to_i * (60 * 60))
  t += (h[:minutes].to_i * 60)
  t += h[:seconds].to_i
  return t
end

def token t, h={}
  if h.has_key? :ttl
    Redis.new.setex(t, h[:ttl], true)
  end
  return Redis.new.get(t)
end

class Phone
  def twilio
    if OPTS[:sid] != ''
      Twilio::REST::Client.new(ENV['PHONE_SID'], ENV['PHONE_KEY'])
    end
  end
  def send_sms h={}
    to = []
    [ h[:to] ].flatten.uniq.each do |t|
      if /^\+1#.+$/.match(t)
        if @cloud.zones.members.include? t.gsub(/\+1/, '')
          @cloud.zone(t.gsub(/\+1/, '')).admins.members.each { |e| to << e }
        else
          to << ENV['ADMIN']
        end
      elsif /^#.+/.match(t)
        if @cloud.zones.members.include? t
          @cloud.zone(t).admins.members.each {|e| to << e }
        else
          to << ENV['ADMIN']
        end
      else
        to << t
      end
    end
    to.each do |t|
      Redis.new.publish "DEBUG.send_sms", "#{t} #{h}"
      if OPTS[:sid] != ""
        if h[:body] != ''
          if h[:image]
            twilio.messages.create(
              to: t,
              from: ENV['PHONE'],
              body: h[:body],
              media_url: [ h[:image] ]
            )
          else
            twilio.messages.create(
              to: t,
              from: ENV['PHONE'],
              body: h[:body]
            )
          end
        end
      end
    end
  end
end
def phone
  Phone.new
end

class Tracks
  include Redis::Objects
  set :adventures
  set :waypoints
  hash_key :players
  def initialize i
    @id = i
  end
  def id; @id; end
  # an adventure track  
  def [] t
    self.adventures << t
    z = Zone.new(t)
    z.adventures << adventure(t)
    Adventure.new(adventure(t))
  end
  # user at waypoint
  def visit u, p
    self.players[u] = p
    uu = U.new(u)
    uu.visited << p
    uu.attr[:waypoint] = p
    uu.attr.incr(:xp)
  end

  #                  U   "say this" -> new track
  # zone, waypoint, password, to, for
  def mark z, w, p, t, f
    @a = Adventure.new(adventure(z))
    @z = Zone.new(z)
    @z.adventures << adventure(z)
    @z.waypoints << @a[w].id
    @u = U.new(w)
    @u.waypoints << @a[w].id
    @a.contributors << @u.id
    @a[w].passwords[p] = { to: t, for: f }
  end
  
  # collect aset of waypoints as a zone.
  def track zone, *waypoints
    self.adventures << zone
    a = Adventure.new(adventure(zone))
    z = Zone.new(zone)
    z.adventures << adventure(zone)
    [waypoints].flatten.each_with_index {|e, i|
      # adventure[waypoint].adventures << adventure(zone)
      a[e].adventures << adventure(zone)
      z.waypoints << a[e].id
    }
    return a
  end
  
  def adventure p
    "#{@id}:#{p}"
  end
end


##
# TRACKS[request.host]track zone, *user
#
# TRACKS[request.host][zone].contributors << @user.id
# TRACKS[request.host][zone][waypoint].passwords[password] = { to: @user.id, for: desc }
#
# TRACKS[request.host][zone].visit(@user.id, waypoint)
#
# TRACKS[request.host][zone][waypoint].stat.incr(zone)
# TRACKS[request.host][zone].stat.incr(waypoint)

TRACKS = Hash.new {|h,k| h[k] = Tracks.new(k) }

class Adventure
  include Redis::Objects
  set :waypoints
  hash_key :attr
  set :contributors
  sorted_set :stat
  hash_key :players
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def [] p
    self.waypoints << p
    Waypoint.new(p)
  end
end

class Waypoint
  include Redis::Objects
  set :adventures
  hash_key :attr
  sorted_set :stat
  hash_key :passwords, marshal: true
  def initialize i
    @id = i
  end
  def id
    @id
  end
end


class Board
  include Redis::Objects
  value :is
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def form
    
  end
  def html
    o = []
    if self.is.value != nil
    @u = U.new(self.is.value)
    o << %[<img src='#{@u.attr[:img]}'>]
    o << %[<p>#{@u.attr[:name] || 'vacant'}</p>]
    else
      o << %[<input type='text' name='board[#{self.id}]' placeholder='user'>]
    end
    return %[<fieldset><legend>#{self.id}</legend>#{o.join('')}</fieldset>]
  end
end

class Contest
  include Redis::Objects
  sorted_set :votes
  sorted_set :voters
  set :pool
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def leader
    x = self.votes[-1]
    return { user: x, votes: self.votes[x] }
  end
end


class Vote
  include Redis::Objects
  sorted_set :votes
  set :pool
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def leader
    x = self.votes[-1]
    return { user: x, votes: self.votes[x] }
  end
end

class Zone
  include Redis::Objects
  set :pool
  set :users
  hash_key :attr
  counter :coins
  set :waypoints
  set :adventures
  set :urls
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def pay a, *u
    [u].flatten.each {|e| Bank.xfer to: e, from: @id, amt: a }
  end
  def rm!
    Bank.xfer from: @id, amt: self.coins.value
    Redis.new.keys.each { |e| if /#{@id}/.match(e); Redis.new.del(e); end }
  end
end

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

class CallCenter
  def initialize phone
    tree = {
      message: "OK",
      file: nil,
      mode: 'callcenter',
      boss: ENV['ADMIN'],
      dispatcher: ENV['ADMIN'],
      pool: [],
      pagers: { '0' => '' }
    }
    @phone = phone
    if !TREE.has_key? @phone
      TREE[@phone] = JSON.generate(tree)
    end
    @tree = JSON.parse(TREE[phone])
  end
  def [] k
    @tree[k.to_s]
  end
  def []= k,v
    @tree[k.to_s] = v
  end
  def << u
    @tree['pool'] << u
    @tree['pool'].uniq!
  end
  def save!
    TREE[@phone] = JSON.generate(@tree)
  end
end

class Sash
  def initialize u, *b
    @pins = ['trip_origin', 'circle', 'adjust', 'stop', 'check_box_outline_blank', 'star', 'star_border', 'stars', 'spa'];
    @u = U.new(u)
  end
  def [] b
    {
      name: b,
      dependancies: DEPS[b],
      for: DESCRIPTIONS[b],
      badges: @u.badges[b],
      awards: @u.awards[b],
      stripes: @u.stripes[b],
      boss: @u.boss[b]
    }
  end
  def << b
    if [DEPS[b.to_sym]].flatten.length > 0
      d = false
      DEPS[b.to_sym].each { |e| if @u.boss[e].to_i > 1 || @u.attr[:boss].to_i > 0; d = true; end  }
    else
      d = true
    end
    if d == true;
      @u.badges.incr(b);
      @u.boss[b] = "#{@u.badges[b].to_i}".length
      @u.stripes[b] = "#{@u.boss[b].to_i}".length
      @u.log << %[<span class='material-icons'>military_awards</span> you earned a #{b} badge.]
    end
  end

  def colors b,f,d
    bg = { 0 => 'darkgrey', 1 => 'white', 2 => 'blue', 3 => 'darkgreen', 4 => 'red' }
    fg = { 0 => 'lightgrey', 1 => 'purple', 2 => 'orange', 3 => 'lightgreen', 4 => 'lightblue' }
    bd = { 0 => 'darkgrey', 1 => 'silver', 2 => 'gold' }
    h =  { fg: fg[f.to_i] || 'gold', bg: bg[b.to_i] || 'black', bd: bd[d.to_i] || 'red' }
  end
  
  def style b,f,d,p,r
    cl = colors(b,f,d)
    bd = ['none', 'solid', 'dotted']
    s = [%[background-color: #{cl[:bg]};]];
    s << %[color: #{cl[:fg]};]
    s << %[border: thick #{bd[p.to_i] || 'dashed'} #{cl[:bd]};]
    s << %[border-radius: #{r}px;]
    return { style: s.join(' '), colors: cl, }
  end

  def lvl
    r = []
    if @u.attr[:boss].to_i > 0
      "#{@u.attr[:boss]}".length.times {
        r << %[<span class='material-icons pin'>#{@pins[@u.attr[:class].to_i + 1]}</span>]
      }
      r << %[<br>]
      @u.attr[:rank].to_i.times { r << %[<span class='material-icons pip'>#{@pins[0]}</span>] }
      p = style(@u.attr[:bg], @u.attr[:fg], @u.attr[:boss].length, @u.attr[:class], 0)
    else
      @u.attr[:rank].to_i.times { r << %[<span class='material-icons pin'>#{@pins[0]}</span>] }    
      p = style(0, 0, 0, 0, 0)
    end
    return %[<h1 id='lvl' style='#{p[:style]}; text-align: center;'>#{r.join('')}</h1>]
  end
  
  def badges
    r, t = [], Hash.new { |h,k| h[k] = 0 }
    @bgs = @u.badges.members(with_scores: true).to_h
    @bss = @u.boss.members(with_scores: true).to_h
    @awd = @u.awards.members(with_scores: true).to_h
    @stp = @u.stripes.members(with_scores: true).to_h
    BADGES.each_pair do |k,v|
      @bss[k.to_s] = "#{@bgs[k.to_s].to_i}".length
      @stp[k.to_s] = "#{@bss[k.to_s].to_i}".length
      t[:badges] += @bgs[k.to_s] || 0
      t[:boss] += @bss[k.to_s] || 0
      t[:awards] += @awd[k.to_s] || 0
      t[:stripes] += @stp[k.to_s] || 0
      p = style(@bss[k.to_s], @bgs[k.to_s], @awd[k.to_s], @stp[k.to_s], 1000);
      r << %[<button class='material-icons badge' name='give[type]' value='#{k}' style='#{p[:style]}'>#{v}</button>]
    end
    @u.stat[:badges] = t[:badges]
    @u.stat[:boss] = t[:boss]
    @u.stat[:awards] = t[:awards]
    @u.stat[:stripes] = t[:stripes]
    return %[<div id='badges'>#{r.join('')}</div>]
  end
end

class U
  include Redis::Objects
  set :waypoints
  set :visited
  sorted_set :wallet
  sorted_set :awards
  sorted_set :stripes
  sorted_set :badges
  sorted_set :stat
  sorted_set :boss
  sorted_set :zap
  sorted_set :zapper
  sorted_set :zapped
  set :votes
  set :zones
  set :jobs
  set :titles
  hash_key :attr
  counter :coins
  list :log
  value :pin, expireat: 180
  value :password
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def sash
    Sash.new(@id)
  end
end



class Tree
  include Redis::Objects
  hash_key :attr
  hash_key :chan
  hash_key :link
  def initialize i
    @id = i
  end
  def id; @id; end
end

class Domain
  include Redis::Objects
  hash_key :attr
  hash_key :stat
  set :zones
  sorted_set :users
  
  def initialize i
    @id = i
  end
  def id; @id; end
  def tree
    Tree.new(@id)
  end
end


@man = Slop::Options.new
@man.symbol '-s', '--sid', "the twilio sid", default: ''
@man.symbol '-k', '--key', "the twilio key", default: ''
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.bool '-I', '--indirect', 'run indirectly', default: false
['-h', '-u', '--help', '--usage', 'help', 'usage'].each { |e| @man.on(e) { puts @man; exit; }}

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)

def train!
  us = []
  IDS.all.each_pair do |user, id|
    b, a = {}, {}
    BADGES.each_pair do |n, i|
      b[n] = ((U.new(id).badges[n].to_f || 0) / 1000).to_f
      a[n] = ((U.new(id).awards[n].to_f || 0) / 1000).to_f
    end
    us << { input: b, output: a }
  end
  BRAIN.train(us)
end
def predict u
  b = {}
  BADGES.each_pair do |n, i|
    b[n] = ((U.new(u).badges[n].to_f || 0) / 1000).to_f
  end
  BRAIN.run(b)
end

class K
  HELP = [
    %[<style>#help li code { border: thin solid black; padding: 1%; }</style>],
    %[<ul id='help'>],
    %[<li><code>cd :name</code><span>focus on a campaign.</span></li>],
    %[</ul>],
    %[<ul>],
    %[<li><button disabled>FS</button> edit the campaign files.</li>],
    %[<li>the campaign index files are the main focus of the campaign.</li>],
    %[<li>adding other files adds pins, app elements, and sub-campaign configuratons.</li>],
    %[</ul>]
  ].join('')
  TERM = [%[<style>#ui { width: 100%; text-align: center; } #ui > input { width: 65%; }],
          %[ #ls { height: 80%; overflow-y: scroll; font-size: small; }],
          %[ #ui > * { vertical-align: middle; }],
          %[ #ui > textarea { height: 80%; width: 100%; }<%= css %></style>],
          %[<h1 id='ui'><a href='/<%= @id %>' class='material-icons' style='border: thin solid black;'>home</a>],
          %[<button type='button' onclick='$("#ls").toggle();'>FS</button>],
          %[<input name='cmd' placeholder='<%= `hostname` %>'>],
          %[<button type='submit' class='material-icons'>send</button></h1>],
          %[<fieldset id='ls' style='display: none;'><legend><a href='/<%= QRO[id] %><%= pwd %>'><%= pwd %></legend></a><%= ls  %></fieldset>],
          %[<div id='output'><%= html %></div>],
          %[#{HELP}],
          %[<script>$(function() { <%= self.scripts.values.join('; ') %>; });</script>]].join('')
  include Redis::Objects
  list :content
  list :scripts
  list :styles
  value :dir
  hash_key :attr
  def initialize(i);
    @id = i;
  end
  def ls
    o = []
    "#{`ls -lha #{self.dir.value}`}".split("\n").each {|e|
      skip = false
      f = e.split(' ')[-1]
      if /^d/.match(e)
        if /\.$/.match(e) || /\.\.$/.match(e)
          b = %[]
          skip = true
        else
          b = %[<button class='material-icons' name='cmd' value='cd("#{f}")'>folder</button>]
        end
      elsif /^total/.match(e)
        b = %[]
        skip = true
      else
        if /.markdown/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>post_add</button>]
        elsif /.erb/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>article</button>]
        elsif /.json/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>list</button>]
        end
      end
      if skip == false
        o << %[<p>#{b} #{e}</p>]
      end
    }
    return "<div>" + o.join('') + "</div>"
  end
  def cd *d
    self.dir.value = %[#{home}/#{d[0]}]
    if !Dir.exist? self.dir.value
      Dir.mkdir(self.dir.value)
    end
    if !File.exist?("#{self.dir.value}/index.json") && d.length > 0
      h = { goal: '', ga: '', fb: '', zone: U.new(@id).attr[:zone] }
      File.open("#{self.dir.value}/index.json", "w") { |f| f.write("#{JSON.generate(h)}"); }
      File.open("#{self.dir.value}/index.erb", "w") { |f| f.write("<h1>Hello, World!</h1>created: </h3><p><% Time.now.utc %></p>"); }
      File.open("#{self.dir.value}/index.markdown", "w") { |f| f.write("# Hello, World!\n\n## markdown is a simple way to organize text to be rendered as html.\n- it supports lists.\n- and tables,\n- etc.\n- google it."); }
    end
    return "#{self.dir.value.gsub(home, '')}"
  end
  def pwd
    if self.dir.value == nil
      self.dir.value = home
    end
    "#{self.dir.value}".gsub(home, '')
  end
  def home
    %[home/#{@id}]
  end
  def term
    ERB.new(TERM).result(binding)
  end
  def clear
    self.content.clear
    return nil
  end
  def peek
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true)
    o = []
    Dir["#{home}/*"].each {|f|
      if /.json/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + File.read(f) + "</fieldset>"
      elsif /.erb/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + ERB.new(File.read(f)).result(binding) + "</fieldset>"
      elsif /.markdown/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + markdown.render(File.read(f)) + "</fieldset>"
      end
    }
    return o.join('')
  end
  def id; @id; end
  
  def html
    o = []
    if self.attr[:file] == nil
      self.content.values.each {|e| o << e }
    else
      f = "#{self.dir.value}/#{self.attr[:file]}"
      if File.exist? f
        ff = File.read(f)
      else
        ff = ''
      end
      o << [%[<input type='hidden' name='editor[file]' value='#{f}'>],
            %[<textarea name='editor[content]' style='width: 100%; height: 80%;'>#{ff}</textarea>]].join('')
      
    end
    return o.join('')
  end
  def js
    self.scripts.values.join('; ')
  end
  def style a, h={}
    o = []; h.each_pair {|k,v| o << %[#{k}: #{v}] }
    self.styles << %[#{a} { #{o.join('; ')} }]
  end
  def css
    self.styles.values.join('')
  end
  def puts(e); return "#{e}"; end;
  def help; ERB.new(HELP).result(binding); end
  def edit(f);
    self.attr[:file] = f
  end
  def conf(*f)
    edit "#{f[0] || 'index'}.json"
  end
  def app(*f)
    edit "#{f[0] || 'index'}.erb"
  end
  def pin(*f)
    edit "#{f[0] || 'index'}.markdown"
  end
  
  
  def button(t, h={}); a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] };
    return %[<button #{a.join(' ')}>#{t}</button>]
  end
  def input(h={}); a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] }; return %[<input #{a.join(' ')}>]; end
  def sh c
    return `#{c}`.chomp!
  end
  def eval(e);
    begin;
      if e == ''; e = 'help'; end
      e.split(';').each { |ea| self.content << "#{self.instance_eval(ea)}".gsub("\n", '<br>') }
    rescue => e
      self.content << "<p>#{e.class} #{e.message}</p>"
    end
  end
end

class Chance
  include Redis::Objects

  list :cards, marshal: true

  def initialize i
    @id = i
  end
  def id; @id; end
  def deal *n
    self.cards.shift(n[0] || 1)
  end
  def deck h={}
    p = []
    self.cards.clear
    h[:decks] || 1.times {|d|
      [h[:suits]].flatten.each { |s|
        [:faces, :numbers].each { |k|
          if h.has_key? k
            [h[k]].flatten.each {|e| p << { deck: d, suit: s, card: e } }
          end
        }
      }
    }
    p.shuffle!
    p.each {|e| self.cards << e }
  end
  def coin
    if rand(2) == 0
      return :heads
    else
      return :tails
    end
  end
  def roll i, &b
    b.call(die(i))
  end
  def die i
    r, tot = [], 0
    ii = i.split('d')
    ii[0].to_i.times { x = rand(ii[1].to_i) + 1; tot += x; r << x }
    return { total: tot, dice: r }
  end
  def zap u
    me = U.new(@id)
    a = "#{me.attr[:xp]}".length + 1
    you = U.new(u)
    d = "#{you.attr[:xp]}".length + 1
    z = die("#{d}d#{you.attr[:rank].to_i + you.attr[:class].to_i}")
    roll("#{a}d#{me.attr[:rank].to_i + me.attr[:class].to_i}") {|h|
      if h[:total] > z[:total]
        r = true
        me.zapper.incr(you.id)
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        you.zapped.incr(me.id)
        me.attr.incr(:xp)
        me.log << %[you zapped #{you.attr[:name] || 'another player'}.]
        you.log << %[you got zapped by #{me.attr[:name] || 'another player'}.]
      else
        r = false
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        me.log << %[you missed #{you.attr[:name] || 'another player'}.]
        you.log << %[#{me.attr[:name] || 'another player'} missed you.]
      end
      { me: h, you: z, result: r }
    }
  end
end

class APP < Sinatra::Base
  set :bind, '0.0.0.0'
  set :server, 'thin'
  set :public_folder, "/home/pi/nomad/public/"
  set :views, "/home/pi/nomad/views/"
  set :sockets, []
  
  helpers do
    def contest c
      Contest.new(c)
    end
    def notify u, h={}
      @u = U.new(u)
      @v = JSON.parse(@u.attr[:vapid])
      Redis.new.publish('NOTIFY', "#{@v}")
      Webpush.payload_send(
        message: JSON.generate(h),
        endpoint: @v['endpoint'],
        p256dh: @v['keys']['p256dh'],
        auth: @v['keys']['auth'],
        vapid: {
          subject: "mailto:#{u}@#{h[:domain]}",
          public_key: @u.attr[:pub],
          private_key: @u.attr[:priv]
        }
      )
    end
    def code c
      if CODE.has_key? c
        return JSON.parse(CODE[c])
      else
        return false
      end
    end

    def banner
      hostname = `hostname`.chomp
      hh = hostname.split('-')
      return hh[0]
    end
    
    def id *i
      if i[0]
        return i[0]
      else
        ii = []; ID_SIZE.times { ii << rand(16).to_s(16) }
        return ii.join('')
      end
    end
    
    def pool
      Redis::Set.new('POOL')
    end
    
    def stats u
      r = [%[<h1 id='stats'>]]
      r << %[<span class='stat'><span>lvl</span><span>#{U.new(u).stat[:lvl]}</span></span>]
      r << %[<span class='stat'><span>xp</span><span>#{U.new(u).stat[:xp]}</span></span>]
      r << %[<span class='stat'><span>gp</span><span>#{U.new(u).stat[:gp]}</span></span>]
      r << %[</h1>]
      return r.join('');
    end
    
    def awards u

    end
    ##
    # badges: background color. network scope.
    # awards: color. network authority.
    # boss: border color. network responsibility.
    # stripes: border. network privledge.
  end
  before {
    @domain = Domain.new(request.host)
    if !Dir.exist? "/home/pi/nomad/public/#{@domain.id}"
      Dir.mkdir("/home/pi/nomad/public/#{@domain.id}")
    end
    
    if "#{ENV['DOMAINS']}".split(' ').include? request.host
      s = 'https'
    else
      s = 'http'
    end
    @path = %[#{s}://#{@domain.id}];
    @term = K.new(params[:u]);
    Redis.new.publish("BEFORE", "#{@path} #{@domain}")
    @tree = Tree.new(@domain.id)
  }
  
  get('/favicon.ico') { return '' }
  get('/manifest.webmanifest') { content_type('application/json'); erb :manifest, layout: false }
  get('/nomad') { erb :nomad }

  get('/term') { if params.has_key?(:reset); @term.attr.delete(:file); end; erb @term.term }
  
#  get('/man') { erb :man }
  get('/a') { erb :a }
  get('/board') { erb :board }
  get('/chance') { erb :chance }
  get('/adventures') { erb :adventures }
  get('/adventure') { erb :adventure }
  get('/waypoint') { erb :waypoint }
  get('/apprtc') { erb :apprtc }
  get('/radio') { erb :radio }
  get('/bank') { @user = U.new(params[:u]); erb :bank }
  get('/sponsor') { @user = U.new(params[:u]); erb :sponsor }
  get('/shares') { @user = U.new(params[:u]); erb :shares }
  get('/shell') { erb :shell, layout: false }
  get('/service-worker.js') { content_type('application/javascript'); erb :service_worker, layout: false }
  post('/sw') {
    @user = U.new(params[:u])
    @user.attr[:vapid] ||= JSON.generate(params[:subscription])
    notify(params[:u], title: @domain.id, body: 'connected')
  }
  
  get '/dx' do
    last_block = Blockchain.new(request.host).last_block
    last_proof = last_block[:proof]
    proof = Blockchain.new(request.new).proof_of_work(last_proof)
    tx = Blockchain.new(request.host).new_transaction(params[:u], 'BANK', Blockchain.new(request.host).block_cost, ['miner'], 'report')
    previous_hash = Blockchain.new(request.host).hash(last_block)
    block = Blockchain.new(request.host).new_block(proof, previous_hash)
    status 200
    
    hf, ha = Hash.new {|h,k| h[k]=0 }, Hash.new {|h,k| h[k]=0 };
    hr = Hash.new {|h,k| h[k]=0 }
    Blockchain.new(request.host).fingers.each_pair {|k,v|
      kk = k.split('#');
      if kk[0] != 'BANK';
        hf[kk[0]] += v;
      end;
      if kk[1] != 'miner';
        ha[kk[1]] += v;
      end
    }
    Blockchain.new(request.host).acts.each_pair {|k,v| kk = k.split(':'); if kk[1] != 'report'; hr[kk[1]] += v; end  } 
    @chain = {
      impressions: hf,
      fingerprints: ha,
      actions: hr 
#      blocks: BLOCKCHAIN.chain.values
    }
    erb :dx
  end
  


  get('/ws') {
    request.websocket do |ws|
      ws.onopen do
        h = { zone: 'network', input: %[{ time: "#{Time.now.utc}" }] }
        ws.send(JSON.generate(h))
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        settings.sockets.each{ |s|
          s.send(msg)
        }
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  }
  get('/answer') {
    if File.exists? "public/#{params[:x]}"
      send_file "public/#{params[:x]}"
    else
      send_file "public/ding.mp3"
    end
  }
  get('/call') {
    Redis.new.publish('CALL', JSON.generate(params))
    content_type 'text/xml'
    @tree = CallCenter.new(params['To'])
    Twilio::TwiML::VoiceResponse.new do | response |
      if !params.has_key? 'Digits'
        response.gather(method: 'GET', action: '/call') do |g|
          case @tree[:mode].to_s
          when 'bossfirst'
            g.dial(record: true, number: @tree[:boss] || OPTS[:boss])
            @tree.pool.each { |e| g.dial(record: true, number: e) }
          when 'dispatcherfirst'
            g.dial(record: true, number: @tree[:dispatcher])
            @tree.pool.each { |e| g.dial(record: true, number: e) }
          when 'bosslast'
            @tree.pool.each { |e| g.dial(record: true, number: e) }
            g.dial(record: true, number: @tree[:boss])
          when 'dispatcherlast'
            @tree.pool.each { |e| response.dial(record: true, number: e) }
            g.dial(record: true, number: @tree[:dispatcher])
          when 'boss'
            g.dial(record: true, number: @tree[:boss])
          when 'dispatcher'
            g.dial(record: true, number: @tree[:dispatcher])
          when 'callcenter'
            if File.exists? "public/#{@tree[:file]}"
              g.play(url: "https://#{@domain.id}/answer?x=#{@tree[:file]}")
            else
              g.say(message: @tree[:message] || @domain.id)
            end
          end
        end
      else
        if m = /^\*(.+)/.match(params['Digits'])
          i = m[1].split('*')
          Redis.new.publish('DIGITS', "#{i}")
          case i.length
          when 2
            if i[0] == '' && @tree[:pagers].has_key?(i[1]) && U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 5
              phone.send_sms( from: params['To'], to: @tree[:dispatcher], body: "[#{params['To']}][DISPATCHER] off")
              @tree[:dispatcher] = @tree[:pagers][i[1]]
              @tree.save!
              phone.send_sms( from: params['To'], to: @tree[:dispatcher], body: "[#{params['To']}][DISPATCHER] on")
              response.say(message: "dispatchers updated.")
            else
              if U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 3
                if IDS.has_key? i[1]
                  Zone.new(i[0]).pool << i[1]
                  @tree.chan[i[0]] = @tree.attr[:lobby]
                  ZONES << i[0]
                  U.new(IDS[i[1]]).zones << i[0]
                  response.say(message: 'added "' + i[1].split('').join(' ') + '" to "' + i[0].split('').join(' ') + '"')
                else
                  response.say(message: "unknown user #{i[1].split('').join(' ')}")
                end
              else
                response.say(message: "insufficient boss level.")
              end
            end
          when 1
            if JOBS.has_key?(i[0]) && U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 3
              o = "job #{i[0]}: #{JOBS[i[0]]}"
            elsif ZONES.include?(i[0]) && U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 3
              z = []; Zone.new(i[0]).pool.members.each { |e| z << e.split('').join(' ') }
              o = "zone #{i[0].split('').join(' ')}: #{z.join(', ')}"
            else
              o = "unknown #{i[0].split('').join(' ')}"
            end
            response.say(message: o)
          end
          response.redirect("#{@path}/call", method: 'GET')
        elsif params['Digits'] == '0*'
          @u = U.new(IDS[params['From'].gsub('+1', '')])
          o = [%[welcome, #{@u.attr[:name]}.]]
          o << %[you have #{@u.coins.value} tokens.]
          o << %[your boss level is #{@u.attr[:boss]}.]
          o << %[you have earned #{@u.badges.members.length} badges.]
          o << %[you are in #{@u.zones.members.length} zones.]
          o << %[and you have #{@u.titles.members.length} titles.]
          response.say(message: o.join(' '))
          response.redirect("#{@path}/call", method: 'GET')
        elsif m = /^0\*(\d)\*(.+)\*(.+)/.match(params['Digits']) && U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 3
          Redis.new.publish("MAGIC", "#{m}")
          if m[3].length > 0
            @i, @u = @tree[:pagers][m[3]], U.new(IDS[@i])
          else
            @i, @u = params['From'].gsub('+1', ''), U.new(IDS[@i])
          end
          if m[1].to_i == 1
            t = "badge"
            b = BDG[m[2].to_i]
            @u.badges.incr(BDG[m[2].to_i] )
          elsif m[1].to_i == 2
            t = "award"
            b = BDG[m[2].to_i]
            @u.awards.incr(BDG[m[2].to_i] )
          elsif m[1].to_i == 3
            t = "stripe"
            b = BDG[m[2].to_i]
            @u.stripes.incr(BDG[m[2].to_i] )
          elsif m[1].to_i == 4
            t = "level"
            b = BDG[m[2].to_i]
            @u.boss.incr(BDG[m[2].to_i] )
          elsif m[1].to_i == 0 && U.new(IDS[params['From'].gsub('+1', '')]).attr[:boss].to_i > 10
            t = "credits"
            b = m[2].to_i
            @u.coins.incr(m[2].to_i)
          end
          phone.send_sms( from: params['To'], to: @i, body: "[#{params['To']}][#{t}] +#{b}")
          phone.send_sms( from: params['To'], to: @tree[:dispatcher], body: "[#{params['To']}][#{@i}][#{tOA}](#{params['Digits']}) #{params['From']} +#{b}")
          response.say(message: "OK")
          response.redirect('https://#{OPTS[:domain]}/call', method: 'GET')
        elsif params['Digits'] == '0'
          response.dial(record: true, number: @tree[:dispatcher])
          response.hangup()
        elsif @tree[:pagers].has_key? params['Digits']
          response.dial(record: true, number: @tree[:pagers][params['Digits']])
          response.hangup()
        elsif JOBS.has_key? params['Digits']
          U.new(IDS[params['From'].gsub('+1', '')]).jobs << params['Digits']
          phone.send_sms( from: params['To'], to: @tree[:dispatcher], body: "[#{params['To']}][JOB](#{params['Digits']}) #{params['From']} -> #{JOBS[params['Digits']]}")
          phone.send_sms( from: params['To'], to: params['From'], body: "[#{params['To']}][JOB](#{params['Digits']}) #{JOBS[params['Digits']]}")
          response.dial(record: true, number: JOBS[params['Digits']])
          JOBS.delete(params['Digits'])
          response.redirect("#{@path}/call", method: 'GET')
        elsif ZONES.include? params['Digits']
          j = []; 6.times { j << rand(9) }; JOBS[j.join('')] = params['From']
          Zone.new(params['Digits']).pool.members.each {|e|
            phone.send_sms( from: params['To'], to: e, body: "[#{params['To']}][#{params['Digits']}][JOB] #{j.join('')}")
          }
          #phone.send_sms( from: params['To'], to: @tree[:dispatcher], body: "[#{params['To']}][#{params['Digits']}] JOB: #{j.join('')}")
          response.say(message: "your request has been received. thank you. goodbye.")
          response.hangup()
        else            
          response.say(message: "please try again.")
          response.redirect("#{@path}/call", method: 'GET')
        end
      end
    end.to_s
  }
  get('/sms') {
    Redis.new.publish('SMS', "#{params}")
    if /^\$\d+/.match(params['Body'])
      s =  Bank.stash(from: BOOK[params['From']], amt: params['Body'].gsub('$', ''), host: request.host)
      b = [%[-#{params['Body']}],
           %[balance: #{s[:balance]}],
           %[credit: #{s[:credit]}],
           %[],
           %[ID: #{s[:id]}]
          ].join("\n")
      phone.send_sms( to: params['From'], body: b )
    else
      s = Bank.recover to: BOOK[params['From']], id: params['Body']
      b = [%[id: #{params['Body']}],
           %[balance: #{s[:balance]}],
           %[credit: #{s[:credit]}],
           %[],
           %[+$#{s[:amt]}]
          ].join("\n")
      phone.send_sms(to: params['From'], body: b)
    end
  }
  get('/') {
    @id = id(params[:u]);
    if params.has_key?(:u);
      @user = U.new(QRI[@id]);
      Bank.mint
      browser = Browser.new(request.user_agent)
      b = %[#{browser.device.id} #{browser.platform.id} #{browser.name} #{browser.full_version}]
      tx = Blockchain.new(request.host).new_transaction('BANK', @user.id, 1, browser.meta, 'rsvp')
      erb :goto;
    else
      erb :landing;
    end
  }
  get('/:q/:c') {
    u = QRI[params[:q]]
    Bank.mint
    browser = Browser.new(request.user_agent)
    b = %[#{browser.device.id} #{browser.platform.id} #{browser.name} #{browser.full_version}]
    tx = Blockchain.new(request.host).new_transaction('BANK', u, 1, browser.meta, params[:c])
    @conf = JSON.parse(File.read("home/#{u}/#{params[:c]}/index.json"))
    @here = @domain.attr.all
    @user = U.new(u).attr.all
    @zone = Zone.new(@conf['zone'] || @user[:zone]).attr.all
    ga = %[<!-- Google Analytics -->
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

ga('create', '<%= @conf["ga"] %>', 'auto');
ga('send', 'pageview');
</script>
<!-- End Google Analytics -->]
    ta = %[<!-- integrate internal analytics trackr -->]
    ERB.new(File.read("home/#{u}/#{params[:c]}/index.erb") + ga + ta).result(binding)
  }
  get('/:u') {
    if QRO.has_key? params[:u]
      if token(params[:u]) == 'true';
        if params[:t].to_i + ((60 * 60) * 48) <= Time.now.utc.to_i
          @vapid = Webpush.generate_key;
          @id = id(params[:u]);
          @user = U.new(@id);
          @user.attr[:pub] = @vapid.public_key
          @user.attr[:priv] = @vapid.private_key
#          qrcode = RQRCode::QRCode.new("#{@path}/?x=#{@user.attr[:zone] || 'solo'}&u=#{QRO[@id]}&b=#{@user.attr[:boss].to_i}&p=#{@user.attr[:xp].to_i}&r=#{@user.attr[:rank].to_i}&c=#{@user.attr[:class].to_i}")
#          png = qrcode.as_png(
#            bit_depth: 1,
#            border_modules: 0,
#            color_mode: ChunkyPNG::COLOR_GRAYSCALE,
#            color: "black",
#            file: nil,
#            fill: "white",
#            module_px_size: 6,
#            resize_exactly_to: false,
#            resize_gte_to: false,
#            size: 200
#          )
#          IO.binwrite("public/#{@domain.id}/QR#{@id}.png", png.to_s)
          pool << @id;
          if /.onion/.match(request.host)
            erb :onion
          else
            erb :index
          end
        else
          # expired link
          w = []; 16.times { w << rand(16).to_s(16) }
          redirect "#{@path}/?w=#{w.join('')}"
        end
      else
        # expired token
        w = []; 16.times { w << rand(16).to_s(16) }
        redirect "#{@path}/?w=#{w.join('')}"
      end
    else
      # does not exist
      redirect "#{@path}"
    end
  }
  post('/') do
    Redis.new.publish 'POST', "#{params}"
    if params.has_key?(:file) && params.has_key?(:u)
      fi = params[:file][:tempfile]
      File.open("public/#{@domain.id}/" + params[:u] + '.img', 'wb') { |f| f.write(fi.read) }
    end
    if params.has_key? :editor
      if !Dir.exists? "home/#{params[:u]}" 
        Dir.mkdir("home/#{params[:u]}")
      end
      File.open("#{params[:editor][:file]}", 'w') {|f| f.write("#{params[:editor][:content]}") }
      @term.attr.delete(:file)
    end
    
    if params.has_key?(:cha) && params[:pin] == Redis.new.get(params[:cha])
      params[:u] = IDS[CHA[params[:cha]]]
      BOOK['+1' + CHA[params[:cha]]] = params[:u]
      LOOK[params[:u]] = '+1' + CHA[params[:cha]]
      U.new(params[:u]).attr[:phone] = CHA[params[:cha]]
      U.new(params[:u]).attr.incr(:key);
      r = []; 100.times { r << rand(16).to_s(16) }
      j = JSON.generate({ utc: Time.now.utc.to_f,
                          id: U.new(params[:u]).id,
                          key: U.new(params[:u]).attr[:key],
                          rnd: r.join('')
                        })
      U.new(params[:u]).attr[:credentials] = j
      U.new(params[:u]).attr[:priv] = Digest::SHA512.hexdigest(j)
      U.new(params[:u]).attr[:pub] = Digest::SHA2.hexdigest(U.new(params[:u]).attr[:priv])
      token(params[:u], ttl: (((60 * 60) * 24) * 7))
      CHA.delete(params[:cha])
      @id = id(params[:u]);
      params.delete(:cha)
      params.delete(:pin)
      @domain.users.incr(@id)
      Redis.new.publish("AUTHORIZE", "#{@path}")
      redirect "#{@path}/#{params[:u]}"
    elsif params.has_key?(:usr)
      cha = []; 64.times { cha << rand(16).to_s(16) }
      qrp = []; 16.times { qrp << rand(16).to_s(16) }
      pin = []; 6.times { pin << rand(9) }
      if !IDS.has_key? params[:usr]
        IDS[params[:usr]] = params[:u]
        QRI[qrp.join('')] = params[:u]
        QRO[params[:u]] = qrp.join('')
      else
        params[:u] = IDS[params[:usr]]
      end
      CHA[cha.join('')] = params[:usr]
      params[:cha] = cha.join('')
      Redis.new.setex params[:cha], 180, pin.join('');
      phone.send_sms to: '+1' + params[:usr], body: "pin: #{pin.join('')}"
      params.delete(:usr)
      erb :landing
    else
      @id = id(params[:u]);
      @by = U.new(@id)

      if params.has_key? :ts
        @user = U.new(params[:u]);
        @user.attr[:seen] = params[:ts]
      elsif params.has_key? :target
        if QRI.has_key? params[:target]
          @user = U.new(QRI[params[:target]])
        else
          @user = U.new(params[:target])
        end
        @user.attr[:seen] = Time.now.utc.to_i
      else
        @user = U.new(@id);
        @user.attr[:seen] = Time.now.utc.to_i
      end
      @user.attr.incr(:xp)
      @by.attr.incr(:xp)
      Redis.new.publish 'POST', "#{@by.id} #{@user.id}"
      
      if params.has_key? :admin && @user.id != @by.id
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} increased your #{params[:admin]}.]
        if params[:admin].to_sym == :boss
          @user.attr.incr(params[:admin].to_sym)
          pr = []
          case @user.attr[:boss]
          when "1"
          when "2"
          when "3"
          when "4"
          when "5"
          when "6"
            # user class
            @user.attr[:class] = 1
            pr = %[vote in contests.]
          when "7"
          when "8"
          when "9"
          when "10"
            # influencer
            @user.attr[:class] = 2
            pr = %[manage content.]
          when "100"
            # brand ambassador
            @user.attr[:class] = 3
            pr = %[send invites.]
          when "1000"
            # brand manager
            @user.attr[:class] = 4
            pr = %[administer a waypoint.]
          when "10000"
            # brand agent
            @user.attr[:class] = 5
            pr = %[administer zones.]
          when "100000"
            # brand operator
            @user.attr[:class] = 6
            pr = %[administer contests.]
          when "1000000"
            # brand owner
            @user.attr[:class] = 7
            pr = %[#{OPTS[:domain]} owner.]
          end
          if pr
            @user.log << %[boss level: #{@user.attr[:boss]}<br>you can now #{pr}]
          end
        elsif params[:admin].to_sym == :rank
          @user.attr.incr(:rank)
        else
          @user.log << %[{params[:admin]}: #{@user.attr[params[:admin].to_sym]}]
        end
      end
                       
      if params.has_key?(:landing) && LOCKED[@domain.id] != 'true'
        LANDING[@domain.id] = params[:landing]
      end          
      
      if params.has_key? :code
        if c = code(params[:code])
          if c[:badge];
            @user.badges.incr(c[:badge]);
            @user.log << %[<span class='material-icons'>#{BADGES[c[:badge]]}</span> you have earned the #{c[:badge]}.<br>#{c[:desc]}]
          end
          [:xp, :rank].each do |e|
            if c[e]; @user.attr.incr(e); end
            @user.log << %[<span class='material-icons'>info</span> +#{e}.]
          end
        else
          
        end
      end

      if params.has_key? :cmd
        @term.eval(params[:cmd]);
      end
      
      if params.has_key? :config 
        l = []
        params[:config].each_pair { |k,v|
          if v != '' && v != @by.attr[k] && k != 'boss' && k != 'class' 
          @by.attr[k] = v
          l << %[#{k} #{v}]
          end
        }
        l.each {|e|
          @user.log << %[<span class='material-icons'>info</span> #{e}]
        }
      end
      
      if params.has_key?(:waypoint)
        # zone, waypoint, password, to, for
        @a = TRACKS[request.host][@user.attr[:zone]]
        Redis.new.publish "WAYPOINT", "#{params[:waypoint]}"
        @a.attr[:location] = params[:waypoint][:location]
        @a.attr[:description] = params[:waypoint][:description]
        @a.attr[:lvl] = params[:waypoint][:lvl]
        if params[:waypoint][:new][:say].length > 0
          v = params[:waypoint][:new]
          TRACKS[request.host].mark @user.attr[:zone], @user.id, v[:say], v[:to], v[:for]
        end
        if params[:waypoint].has_key? :words
        params[:waypoint][:words].each_pair do |k,v|
          TRACKS[request.host][@user.attr[:zone]][@user.id].passwords.delete k
          if v[:say].length > 0
            TRACKS[request.host].mark @user.attr[:zone], @user.id, v[:say], v[:to], v[:for]
          end
          Redis.new.publish "WAYPOINT", "#{k}: #{v}"
        end
        end
#        TRACKS[request.host].mark @user.attr[:zone], params 
#        @user.log << %[<span class='material-icons'>info</span> waypoint #{params[:a]}:#{params[:i]} updated.]
      end

      if params.has_key?(:track) && params[:track] != ''
        Redis.new.publish "TRACK", "#{params[:track]}"
        #a = params[:adventure].split('@')
        TRACKS[request.host].visit @user.id, @by.attr[:zone]
        @user.attr[:track] = params[:track]
      end

      if params.has_key? :board
        params[:board].each_pair { |k,v|
          Board.new(k).is.value = v
        }
        @user.log << %[<span class='material-icons'>info</span> board updated.]
      end
      
      if params.has_key?(:vote) && params[:vote] != ''
        VOTES << params[:vote]
        Contest.new(params[:vote]).pool << @user.id
        @user.attr['vote'] = params[:vote]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} entered you in #{params[:vote]}.]
      end

      if params.has_key?(:contest)
        contest(params[:contest]).votes.incr(@user.id)
        contest(params[:contest]).voters.incr(params[:z])
      end
      
      if params.has_key?(:zone) && params[:zone] != ''
#        ZONES << params[:zone]
#        Zone.new(params[:zone]).pool << @user.id
        @user.zones << params[:zone]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} added you to the #{params[:zone]} zone.]
      end
      
      if params.has_key?(:title) && params[:title] != ''
        TITLES << params[:title]
        @user.titles << params[:title]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} gave you the title "#{params[:title]}".]
      end

      if params.has_key? :zap && params[:zap] == true
        Chance.new(@by.id).zap(@user.id)
      end
      
      if params.has_key?(:give) && params[:give][:type] != nil
        if params[:give][:of] == 'award'
          if @by.boss[params[:give][:type]] > 2
            @user.awards.incr(params[:give][:type])
          end  
        elsif params[:give][:of] == 'vote'
          v = Vote.new(params[:give][:type])
          v.votes.incr @user.id
        elsif params[:give][:of] == 'badge' && params[:give][:desc] != ''
          if @by.boss[params[:give][:type]] > 0
            @user.sash << params[:give][:type]
          end
        elsif params[:give][:of] == 'boss'
          if @by.boss[params[:give][:type]] > 4 || @by.attr[:boss].to_i > 5
            @user.boss.incr params[:give][:type]
          end
        end
        @user.log << %[<span class='material-icons'>#{BADGES[params[:give][:type].to_sym]}</span> #{params[:give][:type]} #{params[:give][:of]} - #{DESCRIPTIONS[params[:give][:type].to_sym]}]
      end
      if params.has_key? :act
        if params[:act] == 'bank'
          Redis.new.publish("OWNERSHIP.bank", "#{params}")
          Bank.wallet[@by.id] = params[:bank][:credit].to_i
          @by.coins.value = params[:bank][:coins].to_i
        elsif params[:act] == 'sponsor'
          Redis.new.publish("OWNERSHIP.sponsor", "#{params}")
          tf = ((60 * 60) * params[:sponsor][:duration].to_i * params[:sponsor][:timeframe].to_i).to_i;
          pay = (2 ** params[:sponsor][:type].to_i).to_i
          cost = ((params[:sponsor][:units].to_i * pay) * tf).to_i;
          @tree.chan[params[:sponsor][:name]] = @by.attr[:zone] || @tree.attr[:lobby] || request.host
          @tree.link[params[:sponsor][:name]] = @by.attr[:zone] || @tree.attr[:lobby] || request.host
          ZONES << params[:sponsor][:name]
          z = Zone.new(params[:sponsor][:name])
          z.attr[:owner] = @by.id
          z.attr[:admin] = @by.id
          z.pool << @by.id
          z.attr[:till] = Time.now.utc.to_i + tf;
          z.attr[:pay] = pay;
          z.attr[:cap] = params[:sponsor][:units].to_i;
          z.attr[:budget] = cost
          @by.zones << params[:sponsor][:name]
          Bank.wallet.decr @by.id, cost
          @by.log(%[<span class='material-icons'>cabin</span>#{params[:sponsor][:name]} <span class='material-icons'>savings</span>#{cost}])
        elsif params[:act] == 'shares'
          Redis.new.publish("OWNERSHIP.shares", "#{params}")
          if ENV['OWNERSHIP'] == 'franchise'
            @by.attr[:tos] = params[:tos][:terms]
            @by.attr[:agreed] = params[:tos][:agreed]
          end
          if params[:shares][:mode] == 'sell' && Shares.by(request.host)[@by.id].to_i >= params[:shares][:qty].to_i
            Bank.wallet.incr @by.id, params[:shares][:qty].to_i * Shares.cost(request.host)
            Shares.burn @domain.id, @by.id, params[:shares][:qty].to_i
            @by.log(%[-<span class='material-icons'>confirmation_number</span>#{params[:shares][:qty]} +<span class='material-icons'>savings</span>#{params[:shares][:qty].to_i * Shares.cost(request.host)}])
          elsif params[:shares][:mode] == 'buy' && Bank.wallet[@by.id] >= (params[:shares][:qty].to_i * Shares.cost(request.host))
            Bank.wallet.decr @by.id, params[:shares][:qty].to_i * Shares.cost(request.host)
            Shares.mint @domain.id, @by.id, params[:shares][:qty].to_i
            @by.log(%[+<span class='material-icons'>confirmation_number</span>#{params[:shares][:qty]} -<span class='material-icons'>savings</span>#{params[:shares][:qty].to_i * Shares.cost(request.host)}])
          end
        end
      end

      if params.has_key? :xfer && params[:xfer] != ''
        Bank.xfer from: @by.id, to: @user.id, amt: params[:xfer]
        @by.log << %[<span class='material-icons'>toll</span> #{params[:xfer]} <-- #{@by.coins.value}]
        @user.log << %[<span class='material-icons'>toll</span> #{params[:xfer]} --> #{@user.coins.value}]
      end
      
      if params.has_key?(:message) && params[:message] != ''
        p = patch(@by.attr[:class], @by.attr[:rank], @by.attr[:boss], @by.attr[:stripes], 0)
        @user.log << %[<span style='#{p[:style]} padding-left: 2%; padding-right: 2%;'>#{@by.attr[:name] || @by.id}</span>#{params[:message]}]
      end

      if params.has_key?(:send) && params[:send][:number].length == 10
        if params[:send][:mode] == 'invite'
          tok = []; 16.times { tok << rand(16).to_s(16) }
          phone.send_sms( from: ENV['PHONE'], to: params[:send][:number], body: "invite: #{@path}/?w=#{tok.join('')}")
        else
          z = []; 12.times { z << rand(16).to_s(16) }; @z = z.join('')
          r = "#{@by.attr[:name]}\n#{@by.attr[:pitch]}\n#{@path}/?u=#{QRO[@by.id]}&z=#{@z}"
          phone.send_sms( from: ENV['PHONE'], to: params[:send][:number], body: r)
        end
      end
      
      if params.has_key? :quick
        ###################################################################
        @tree = CallCenter.new(ENV['PHONE'])
        r = ["thank you for your request."]
        r << "One of our agents will contack you shortly."  
        r << "You may also contact us immediately at this number."
        r << "\n"
        r << "Gracias por su solicitud."
        r << "Te llamaremos lo antes posible."
        r << "También puede ponerse en contacto con nosotros inmediatamente en este número."
        phone.send_sms( from: ENV['PHONE'], to: @tree[:dispatcher], body: "#{params[:quick][:phone]} #{params[:quick][:rx]}")
        phone.send_sms( from: ENV['PHONE'], to: params[:quick][:phone], body: r.join("\n"))                  
      end
      
      if params.has_key? :login
        if params[:login][:username].length > 0
          if LOGINS[params[:login][:username]] == params[:login][:password]
            if !IDS.has_key? params[:login][:username]
              IDS[params[:login][:username]] = @id
              BOOK[params[:login][:username]] = @id
              LOOK[@id] = params[:login][:username]
              qrp = []; 16.times { qrp << rand(16).to_s(16) }
              QRI[qrp.join('')] = IDS[params[:login][:username]]
              QRO[IDS[params[:login][:username]]] = qrp.join('')
              @by = U.new(IDS[params[:login][:username]])
              @by.password.value = LOGINS[params[:login][:username]]
            end
            
            @by = U.new(IDS[params[:login][:username]])
            if !Dir.exist? "home/#{@by.id}"
              Dir.mkdir("home/#{@by.id}")
            end
            if @by.password.value.to_s == params[:login][:password].to_s
              token(@by.id, ttl: (((60 * 60) * 24) * 7))
              @domain.users.incr(@by.id)
              redirect "#{@path}/#{@by.id}"
            end
          else
            redirect "#{@path}"
          end
        else
          redirect "#{@path}"
        end
      end
      
      if params.has_key? :landing
        redirect "#{@path}"
      elsif params.has_key? :quick
        redirect "#{@path}"
      elsif params.has_key? :cmd
        redirect "#{@path}/term?u=#{params[:u]}"
      elsif params.has_key? :code
        redirect "#{@path}/?u=#{params[:u]}&x=#{params[:x]}&ts=#{params[:ts]}&z=#{params[:z]}"
      elsif params.has_key? :a
        redirect "#{@path}/adventure?u=#{params[:u]}&a=#{params[:a]}"
      else
        redirect "#{@path}/#{@by.id}"
      end
    end
  end
end

def cam n, u
CAMS[n] = u
end

module Box
  def self.user u
    U.new(u)
  end
  def self.[] k
      U.new(IDS[k])
  end
  def self.domain d
    Domain.new(d)
  end
end



Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0 )

def op u
  if IDS.has_key? u
    @u = U.new(IDS[u])
    @u.attr[:boss] = 999999999
    @u.attr[:class] = 7
    @u.coins.value ||= 999999999
  end
end
op ENV['admin']
LOGINS.keys.each {|e| op e }

begin
  host = `hostname`.chomp
  if OPTS[:interactive]
    Signal.trap("INT") { File.delete("/home/pi/nomad/nomad.lock"); exit 0 }
    Process.detach( fork { APP.run! } )                                    
    Pry.config.prompt_name = :nomad
    Pry.start(host)
  elsif OPTS[:indirect]
    Signal.trap("INT") { puts %[[EXIT][#{Time.now.utc.to_f}]]; exit 0 }
    puts "##### running indirectly... #####"
    Pry.config.prompt_name = :nomad
    Pry.start(host)
  else
    APP.run!
  end
rescue => e
  Redis.new.publish "ERROR", "#{e.full_message}"
  exit
end

