load 'lib/u.rb'
load 'lib/zone.rb'
load 'lib/phone.rb'
load 'lib/brain.rb'
load 'lib/ownership.rb'
load 'lib/term.rb'
load 'lib/tracks.rb'
load 'lib/chance.rb'

def id *i
  if i[0]
    return i[0]
  else
    ii = []; ID_SIZE.times { ii << rand(16).to_s(16) }
    return ii.join('')
  end
end

def useradd u
  if "#{u}".length > 0
  @id = id(IDS[u]);
  IDS[u] = @id
  BOOK[u] = @id
  LOOK[@id] = u
  qrp = []; 16.times { qrp << rand(16).to_s(16) }
  QRI[qrp.join('')] = IDS[u]
  QRO[IDS[u]] = qrp.join('')
  @by = U.new(IDS[u])
  @by.password.value = LOGINS[u]
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

class Gov
  def initialize
    
  end
  def [] k
    Board.new(k)
  end
  def html
    a = []
    ['network', SHARES.all.keys].flatten.each {|e| a << Board.new(e).html }
    return a.join('')
  end
  def gov
    h = Hash.new {|h,k| h[k] = {}}
    all.each_pair { |k,v| v.each_pair { |kk, vv| h[k][kk] = vv } }
    return h
  end
end

GOV = Gov.new

class Board
  include Redis::Objects
  set :board
  set :titles
  set :zones
  set :pool
  set :users
  value :type
  sorted_set :hire
  sorted_set :pay
  
  def initialize d, *p
    if p[0]
      @id = "#{p[0]}.#{d}"
    else
      @id = "#{d}"
    end
    @domain = Domain.new(@id)
  end
  def id; @id; end
  def positions
    a = []
    self.board.members.each {|e| a << Position.new("#{e}@#{@domain.id}").id }
    return a
  end
  def govern *type
    case type[0]
    when :s
      self.board.clear
      self.board << :owner
    when :c
      self.board.clear
      self.board << :president
      self.board << :treasurer
    when :nomad
      self.board.clear
      self.board << :boss
      self.board << :procurement
      self.board << :fulfilment
      self.board << :operations
    end
    self.board.members
  end
  def all
    h = {}
    self.board.members.each {|e| h[e] = Position.new("#{e}@#{@domain.id}").is.value }
    return h
  end
  def html
    o = [];
    self.board.members.each {|e| o << Position.new("#{e}@#{@domain.id}").html }
    return %[<fieldset><legend>#{@domain.id}</legend>#{o.join('')}</fieldset>]
  end
  def [] k
    self.board << k
    Position.new("#{k}@#{@domain.id}")
  end
end

class Position
  include Redis::Objects
  sorted_set :nominate
  counter :election
  sorted_set :votes
  sorted_set :voted
  value :is
  counter :state
  def initialize i
    @id = i
    if self.is.value == nil
      self.state.value = 1
    end
  end
  def id
    @id
  end
  def holder
    is = 'vacant'
    if self.is.value != nil
      is = self.is.value
    end
    if self.is.value == nil && self.votes.revrange(0, -1)[0] != nil
      is = self.votes.revrange(0, -1)[0] 
    end
    if self.is.value == nil && self.votes.revrange(0, -1)[0] == nil && self.nominate.revrange(0, -1)[0] != nil
      is = self.nominate.revrange(0, -1)[0]
    end
    return is
  end
  def vote u, f
    if self.state.value > 0
    self.voted.increment(u)
    if self.voted[u] == 1
      self.votes.increment(f)
    end
    else
      self.nominate.increment(u)
      if self.nominate.members.length >= self.election.value
        self.state.value = 1
        self.nominate.members.each {|e| self.votes[e] = 0 }
      end
    end
  end
  def elect
    self.state.value = 0
    self.is.value = self.votes.revrange(0,-1)[0]
    self.votes.clear
    self.voted.clear
  end
  def html
    o = []
    @u = U.new(holder)
    if @u.attr.has_key? :img
      o << %[<div style='width: 100%; text-align: center;'><img style='width: 100%;' src='#{@u.attr[:img]}'></div>]
    end
    o << %[<p syle='width: 100%; text-align: center;'><a href='/?u=#{QRO[@u.id]}' style='color: black; text-decoration: none;'>#{@u.attr[:name] || 'anonymous'}</a></p>]
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

class Comms
  def initialize user, host
    @user = U.new(user)
    @host = host
    if ENV['cluster'] == 'localhost' && /.onion/.match(host)
      @here = host
    else
      @here = ENV['CLUSTER']
    end
    if MUMBLE.has_key? @here
      @port = MUMBLE[@here]
    else
      @port = ENV['MUMBLE']
    end
  end

  def cluster
    return %[mumble://#{@user.attr[:name] || 'nomad'}@#{ENV['CLUSTER']}:#{@port}/?version=1.2]                                                                   end
  def onion
    return %[mumble://#{@user.attr[:name] || 'nomad'}@#{Redis.new.get('ONION')}:#{@port}/?version=1.2]                                                           end
  def host
    return %[mumble://#{@user.attr[:name] || 'nomad'}@#{@host}:#{@port}/?version=1.2]
  end
  def here
    return %[mumble://#{@user.attr[:name] || 'nomad'}@#{@here}:#{@port}/?version=1.2]
  end
end

class Vote
  include Redis::Objects
  sorted_set :votes
  set :voters
  set :pool
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def leaderboard
    a = []
    self.votes.revrange(0, -1).each {|e| a << { e => self.votes[e] } }
    return a
  end
  def leader
    x = self.votes[-1]
    return { user: x, votes: self.votes[x] }
  end
end

def votes
  v = {}
  VOTES.members.each {|e| v[e] = Vote.new(e).leaderboard }
  return v
end



class JOB
  include Redis::Objects
  set :pool
  def initialize i
    @id = i
  end
  def id; @id; end
end
class Job
  include Redis::Objects
  hash_key :attr
  hash_key :item, marshal: true
  set :items
  def initialize u, j
    @user = U.new(u)
    @zone = Zone.new(@user.attr[:sponsor])
    JOB.new(j).pool << @user.id
    JOBS[j] = @user.id
    @id = "#{@user.id}:#{@user.attr[:sponsor]}:#{j}"
    @zone.jobs[@id] = @user.id
    @user.jobs << j
  end
  def id; @id; end
  def << h={}
    self.items << h[:body]
    @user.items << h[:body]
    @zone.items["#{@id}:#{h[:body]}"] = @user.id
    self.item["#{@id}:#{h[:body]}"] = h
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

class Badge
  def initialize u
    @id = u
    @user = U.new(u)
    if QRO.has_key? u
      @uid = QRO[u]
    else
      @uid = u
    end
  end
  def z
    zz = []; 12.times { zz << rand(16).to_s(16) };
    zzz = zz.join('')
    # do something on z create
    return zzz
  end
  def ts
    t = Time.now.utc.to_i
    # do something on ts create
    return t
  end
  def id; @id; end
  def member
    ##
    # key:
    # u: ORO[@id]
    # x: sponsor zone
    # b: boss level (brand privledge)
    # c: class level (network privledge)
    # r: adventure level ("completed adventures".length)
    # z: adventure neuton
    zo = CGI.escape("#{@user.attr[:zone] || 'solo' }")
    if QRO.has_key? @id
      return %[?b=#{@user.attr[:boss].to_i}&p=#{@user.attr[:xp].to_i}&r=#{@user.attr[:rank].to_i}&c=#{@user.attr[:class].to_i}&x=#{zo}&u=#{QRO[@id]}&z=#{z}]
    else
      return %[?b=#{@user.attr[:boss].to_i}&p=#{@user.attr[:xp].to_i}&r=#{@user.attr[:rank].to_i}&c=#{@user.attr[:class].to_i}&x=#{zo}&u=#{@id}&z=#{z}]
    end
  end
  def user
    ##
    # ts: last reload time index
    return %[#{member}&ts=#{ts}]
  end
  def zap
    return %[NOMAD@id]
  end
end



WE = Hash.new { |h,k| h[k] = Cerebrum.new }
ME = Hash.new {|h,k| h[k] = Hash.new { |hh, kk| hh[kk] = Me.new("#{k}:#{kk}") } }
TRACKS = Hash.new {|h,k| h[k] = Tracks.new(k) }
BLOCKCHAIN = Blockchain.new('/')
