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
  food: 'knowledgable on the subject of food.',
  bike: 'able to operate a pedicab.',
  grill: 'knowlegable on the subject of grilled meat.',
  pathfinder: 'able to manage multiple transportation vectors.',
  kids: 'child friendly.',
  meals: 'knowlegable on the subject of sit down meals.',
  pizza: 'knowlegable on the subject of pizza.',
  bar: 'knowlegable on the subject of local bars.',
  asian: 'knowlegable on the subject of asian food.',
  coffee: 'knowlegable on the subject of local coffee.',
  influence: 'knowlegable on the subject of ultra-exclusive local events.',
  referral: 'knowlegable on the subject of local events.',
  directions: 'able to find things.',
  adventure: 'qualified to conduct adventures.',
  radio: 'qualified to use a radio.',
  dispatch: 'managing network radio operatons.',
  farmer: 'knowlegable on the subject of growing things.',
  cannabis: 'knowlegable on the subject of cannabis.',
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
require 'faraday'

load "bin/colorize.rb"


CRON = Rufus::Scheduler.new
DOMAINS = Redis::Set.new("DOMAINS")
VOTES = Redis::Set.new("VOTES")
ZONES = Redis::Set.new("ZONES")
TITLES = Redis::Set.new("TITLES")
CHA = Redis::HashKey.new('CHA')
IDS = Redis::HashKey.new('IDS')
DEVS = Redis::HashKey.new('DEVS')
DB = Redis::HashKey.new('DB')
BOOK = Redis::HashKey.new('BOOK')
PAGERS = Redis::HashKey.new('PAGERS')
LOOK = Redis::HashKey.new('LOOK')
HEAD = Redis::HashKey.new('HEAD')
LANDING = Redis::HashKey.new('LANDING')
FOOT = Redis::HashKey.new('FOOT')
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
OTP = Redis::HashKey.new('OTP')
OTK = Redis::HashKey.new('OTK')
LVLS = Redis::HashKey.new("LVLS")
SASH = Redis::HashKey.new("SASH")
LOAD = Redis::HashKey.new("LOAD")
INIT = Redis::HashKey.new("INIT")
CSS = Redis::HashKey.new("CSS")

PINS = ['trip_origin', 'circle', 'adjust', 'stop', 'check_box_outline_blank', 'star', 'star_border', 'stars', 'spa'];

WE = Hash.new { |h,k| h[k] = Cerebrum.new }
ME = Hash.new {|h,k| h[k] = Hash.new { |hh, kk| hh[kk] = Me.new("#{k}:#{kk}") } }



class Me
  def initialize u
    @user = U.new(u)
    @brain = Cerebrum.new
    @mood = Sentimental.new
    @mood.load_defaults
    @mood.threshold = 0.1
  end
  def mood
    @mood
  end
  def feel f
    @mood.sentiment f
    @mood.score f
  end
  
  def brain
    @brain
  end
  def learn loc
    da = {}
    @user.badges.members(with_scores: true).to_h.each_pair do |b, s|
      da[b] = (s / 1000000).to_f
    end
    dat = { input: da, output: { "#{loc}" => 1 }}
    @brain.train([dat])
  end
  def predict
    u = @user.badges.members(with_scores: true).to_h
    @brain.run(u)
  end
end

def learn d, u, l
  da = {}
  U.new(u).badges.members(with_scores: true).to_h.each_pair do |b, s|
    da[b] = (s / 1000000).to_f
  end
  dat = { input: da, output: { "#{l}" => 1 }}
  { me: ME[d][u].learn(l), we: WE[d].train([dat]) }
end

def predict d, u
  uu = U.new(u).badges.members(with_scores: true).to_h
  { me: ME[d][u].predict, we: WE[d].run(uu) }
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
    if "#{t}".length > 0
    self.adventures << t
    z = Zone.new(t)
    z.adventures << adventure(t)
    Adventure.new(adventure(t))
    end
  end
  # user at waypoint
  def visit u, p
    if "#{u}".length > 0 && "#{p}".length > 0
      self.players[u] = p
      uu = U.new(u)
      uu.visited << p
      uu.attr[:waypoint] = p
      uu.attr.incr(:xp)
    end
  end

  #                  U   "say this" -> new track
  # zone, waypoint, password, for
  def mark z, w, p, f, a
    Redis.new.publish "WAYPOINT.mark", "#{z} #{w} #{p} #{f}"
    if "#{z}".length > 0 && "#{w}".length > 0 && "#{p}".length > 0 && "#{f}".length > 0
    @a = Adventure.new(adventure(z))
    @z = Zone.new(z)
    @z.adventures << adventure(z)
    @z.waypoints << @a[w].id
    @u = U.new(w)
    @u.waypoints << @a[w].id
    @a.contributors << @u.id
    @a[w].passwords[p] = { for: f }
    @a[w].attr[:goto] = a
    end
  end
  
  # collect aset of waypoints as a zone.
  def track zone, *waypoints
    if "#{zone}".length > 0
    self.adventures << zone
    a = Adventure.new(adventure(zone))
    z = Zone.new(zone)
    z.adventures << adventure(zone)
    [waypoints].flatten.each_with_index {|e, i|
      # adventure[waypoint].adventures << adventure(zone)
      if "#{e}".length > 0
      a[e].adventures << adventure(zone)
      z.waypoints << a[e].id
      end
    }
    return a
    end
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
    if "#{p}".length > 0
    self.waypoints << p
    Waypoint.new(p)
    end
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


class Zone
  include Redis::Objects
  set :pool
  set :users
  hash_key :jobs
  hash_key :items
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
    bg = { 0 => 'darkgrey', 1 => 'white', 2 => 'lightblue', 3 => 'lightgreen', 4 => 'red' }
    fg = { 0 => 'lightgrey', 1 => 'purple', 2 => 'orange', 3 => 'green', 4 => 'blue', 5 => 'red', 6 => 'brown', 7 => 'yellow', 8 => 'magenta' }
    bd = { 0 => 'darkgrey', 1 => 'purple', 2 => 'orange', 3 => 'green', 4 => 'blue', 5=> 'red', 6 => 'brown', 7 => 'yellow', 8 => 'magenta' }
    h =  { fg: fg[f.to_i] || 'gold', bg: bg[b.to_i] || 'black', bd: bd[d.to_i] || 'gold' }
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
    r, ps = [], []
    if @u.attr[:boss].to_i > 0
      "#{@u.attr[:boss]}".length.times {
        ps << %[<span class='material-icons pin'>#{PINS[@u.attr[:class].to_i + 1]}</span>]
      }
    end
    @u.attr[:rank].to_i.times { r << %[<span class='material-icons pin'>#{PINS[0]}</span>] }    
    p = style("#{@u.attr[:boss].to_i}".length - 1, "#{@u.attr[:xp].to_i}".length - 1, @u.attr[:class], @u.attr[:class], 0)
    return %[<div id='lvl' style='#{p[:style]};'><div>#{ps.join('')}</div><div>#{r.join('')}</div></div>]
  end
  
  def badges
    r, t = [], Hash.new { |h,k| h[k] = 0 }
    @bgs = @u.badges.members(with_scores: true).to_h
    @bss = @u.boss.members(with_scores: true).to_h
    @awd = @u.awards.members(with_scores: true).to_h
    @stp = @u.stripes.members(with_scores: true).to_h
    BADGES.each_pair do |k,v|
      @u.boss[k.to_s] = "#{@bgs[k.to_s].to_i}".length - 1
      @u.stripes[k.to_s] = "#{@awd[k.to_s].to_i}".length
      t[:badges] += @bgs[k.to_s] || 0
      t[:boss] += @bss[k.to_s] || 0
      t[:awards] += @awd[k.to_s] || 0
      t[:stripes] += @stp[k.to_s] || 0
      if @bgs[k.to_s].to_i > 9
        g = "#{@bgs[k.to_s].to_i}"[-1]
      else
        g = @bgs[k.to_s]
      end
      if @awd[k.to_s].to_i > 9
        w = "#{@awd[k.to_s].to_i}"[0]
      else
        w = @awd[k.to_s]
      end
      p = style(@bss[k.to_s], g, w, @stp[k.to_s], 1000);
      r << %[<button class='material-icons badge' name='give[type]' value='#{k}' style='#{p[:style]}'>#{v}</button>]
    end
    @u.stat[:badges] = t[:badges]
    @u.stat[:boss] = t[:boss]
    @u.stat[:awards] = t[:awards]
    @u.stat[:stripes] = t[:stripes]
    return %[<div id='badges'>#{r.join('')}</div>]
  end
end

JOBS = Redis::HashKey.new('JOBS')

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

class U
  include Redis::Objects
  set :waypoints
  set :visited
  set :jobs
  set :items
  set :reps
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
  counter :zaps
  counter :spaz
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

@man = Slop::Options.new
@man.symbol '-s', '--sid', "the twilio sid", default: ''
@man.symbol '-k', '--key', "the twilio key", default: ''
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.bool '-I', '--indirect', 'run indirectly', default: false
['-h', '-u', '--help', '--usage', 'help', 'usage'].each { |e| @man.on(e) { puts @man; exit; }}

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)

class Ui
  def initialize t
    @title = t
    @html = []
  end
  def html
    return %[<fieldset><legend>#{@title}</legend>#{@html.join('')}</fieldset>]
  end
  def button(t, h={});
    a = [];
    h.each_pair { |k,v|
      a << %[#{k}='#{v}']
    };
    @html << %[<button #{a.join(' ')}>#{t}</button>]
  end
  def input(h={});
    a = [];
    h.each_pair { |k,v|
      a << %[#{k}='#{v}']
    };
    @html << %[<input #{a.join(' ')}>];
  end
end
class UI
  def initialize
    @ui = Hash.new {|h,k| h[k] = Ui.new(k) }
  end
  def [] k
    @ui[k]
  end
  def html
    a = []
    @ui.each_pair {|k,v| a << v.html }
    return a.join('') 
  end
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
          %[<h1 id='ui'>],
          %[<a href='/<%= @id %>' class='material-icons' style='border: thin solid black;'>home</a>],
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
  value :res, marshal: true
  value :try
  def initialize i
    @id = i
    @u = U.new(@id)
  end
  def id; @id; end
  def deal *n
    a, aa, t = [], [], 0
    [self.cards.shift(n[0].to_i || 1)].flatten.each {|e| t += e[:value]; a << e }
    a.each {|e| aa << %[#{e[:card]}#{e[:suit]}] }
    return { total: t, result: aa }                            
  end
  def try?
    if @u.attr.has_key?(:chance) && @u.attr[:chance] != 'none'
      return true
    else
      return false
    end
  end
  def try!
    @n = @u.attr[:rank].to_i + 1
    case @u.attr[:chance]
    when 'coin'
      t, a = 0, []; @n.times { c = coin; t += c[:total]; a << c[:result] }
      self.res.value = { total: t, result: a }
    when 'card'
      if self.cards.values.length - @n  >= 0
        deck
      end
      self.res.value = deal(@n)
    when 'dice'
      self.res.value = roll("#{@n}d#{@u.attr[:class].to_i + 1}") {|r| r }
    end
    self.try.value = success(result)
    return success?
  end
  def success i
    Redis.new.publish("CHANCE.success", "#{i} #{@u.attr.all}")
    if i[:total].to_i >= @u.attr[:rank].to_i
      return true
    else
      return false
    end
  end
  def success?
    self.try.value
  end
  def result
    self.res.value
  end
  def deck h={}
    de = []
    hh = {
      suits: ["&#9829;", "&#9830;", "&#9824;", "&#9827;"],
      numbers: (2..10).to_a,
      faces: [ :A, :K, :Q, :J ],
      special: [ :"&#x1F0CF;", :"&#x1F004;" ],
    }.merge(h)
    Redis.new.publish("CHANCE.deck", "#{hh}")
    self.cards.clear
      [hh[:suits]].flatten.each { |s|
        Redis.new.publish("CHANCE.deck.s", "#{s}")
        [:faces, :numbers].each { |k|
          Redis.new.publish("CHANCE.deck.k", "#{k}")
          if hh.has_key? k.to_sym
            [hh[k]].flatten.each {|e|
              if /\d+/.match("#{e}")
                v = e.to_i
              else
                v = 10
              end
              de << { suit: s, card: e, value: v }
              Redis.new.publish("CHANCE.deck.card", "s#{s} c#{e} v#{v}")
            }
          end
        }
      }
      [hh[:special]].flatten.each {|e| de << { suit: "#", card: e, value: 0 };
        Redis.new.publish("CHANCE.deck.special", "#{e}")
      }
    Redis.new.publish("CHANCE.deck.de", "#{de}")
    de.shuffle!
    de.each {|e| self.cards << e }
  end
  def coin
    c = rand(2)
    if c == 0
      t = "arrow_circle_up"
    else
      t = "arrow_circle_down"
    end
    Redis.new.publish("CHANCE.coin", "#{c} #{t}")
    { total: c, result: %[<span class='material-icons' style='vertical-align: middle;'>#{t}</span>] }
  end
  def roll i, &b
    b.call(die(i))
  end
  def die i
    r, tot = [], 0
    ii = i.split('d')
    ii[0].to_i.times { x = rand(ii[1].to_i) + 1; tot += x; r << x }
    Redis.new.publish("CHANCE.dice", "#{tot} #{r}")
    return { total: tot, result: r }
  end
  def zap u
    me = U.new(@id)
    a = "#{me.attr[:xp]}".length + 1
    you = U.new(u)
    me.zaps.increment
    you.spaz.increment
    d = "#{you.attr[:xp]}".length + 1
    z = die("#{d}d#{you.attr[:rank].to_i + you.attr[:class].to_i}")
    roll("#{a}d#{me.attr[:rank].to_i + me.attr[:class].to_i}") {|h|
      ic = %[<span class='material-icons'>crisis_alert</span>]
      icn_hit = %[<span class='material-icons' style='color: red;'>ads_click</span>]
      icn_miss = %[<span class='material-icons' style='color: green;'>adjust</span>]
      if h[:total] > z[:total]
        r = 1
        me.zapper.incr(you.id)
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        you.zapped.incr(me.id)
        me.attr.incr(:xp)
        icn = %[<span class='material-icons'>crisis_alert</span>]
        me.log << %[#{icn_hit} you zapped #{you.attr[:name] || 'another player'}.]
        you.log << %[#{icn_hit} you got zapped by #{me.attr[:name] || 'another player'}.]
      else
        r = 0
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        icn = %[<span class='material-icons'>crisis_alert</span>]
        me.log << %[#{icn_miss} you missed #{you.attr[:name] || 'another player'}.]
        you.log << %[#{icn_miss} #{me.attr[:name] || 'another player'} missed you.]
      end
      me.attr.incr(:xp)
      you.attr.incr(:xp)
      u, t = 0, 0
      me.zapper.members(with_scores: true).to_h.each_pair {|k,v| u += 1; t += v }
      me.attr[:rank] = ( "#{me.zaps.value}".length + "#{me.spaz.value}".length ) - 1
      you.attr[:rank] = ( "#{you.zaps.value}".length + "#{you.spaz.value}".length ) - 1
      me.log << %[<span class='material-icons'>emoji_events</span>rank: #{me.attr[:rank]}]
      you.log << %[<span class='material-icons'>emoji_events</span>rank: #{you.attr[:rank]}]
      { me: h, you: z, total: r }
    }
  end
end

class APP < Sinatra::Base
  set :bind, '0.0.0.0'
  set :server, 'thin'
  set :public_folder, "/home/pi/nomad/public/"
  set :views, "/home/pi/nomad/views/"
  set :sockets, []
  enable :sessions
  helpers do
    def privs u
      @user = U.new(u);
      pr = Hash.new {|h,k| h[k] = [] }
   
      if @user.attr[:class].to_i >= 0
        pr[0] << %[scanning qrcodes.]
        pr[0] << %[send tokens.]
        pr[0] << %[award badges.]
        pr[0] << %[assign waypoints.]
        pr[0] << %[post waypoint notifications.]
      end
      
      if @user.attr[:class].to_i >= 1
        pr[1] << %[message the team (<span class='material-icons' style='vertical-align: middle;'>star</span>) and customers (<span class='material-icons' style='vertical-align: middle;'>stars</span>) with updates and offers for sponsor.]
        pr[1] << %[create passwords for offers at your waypoint (<span class='material-icons' style='vertical-align: middle;'>edit</span>).]
        pr[1] << %[share your rsvp with a text message (<span class='material-icons' style='vertical-align: middle;'>contact_phone</span>).]
        pr[1] << %[add a pitchline, contact phone-number and link-to-follow to your rsvp.]
        pr[1] << %[add a profile picture to your rsvp.]
        pr[1] << %[sign in remote devices.]
        pr[1] << %[use the bank (<span class='material-icons' style='vertical-align: middle;'>savings</span>) to transfer tokens and credits.]
        pr[1] << %[view reports (<span class='material-icons' style='vertical-align: middle;'>report</span>).]
      end
      if @user.attr[:class].to_i >= 2
        pr[2] << %[advance user rank.]
      end
      if @user.attr[:class].to_i >= 3
        pr[3] << %[invite new users.]
      end
      if @user.attr[:class].to_i >= 4
        
      end
      if @user.attr[:class].to_i >= 5
        pr[5] << %[promote user class.]
      end
      if @user.attr[:class].to_i >= 6
        
      end
      if @user.attr[:class].to_i > 6
        pr[7] << %[basically, you can do everything.]
      end
      pri = []
      pr.each_pair {|k,v|
        o = []
        v.each {|e| o << %[<li>#{e}</li>] }
        pri << %[<fieldset><legend><span class='material-icons' style='vertical-align: middle; font-size: small; margin: 0;'>#{PINS[k]}</span></legend><ul style='font-size: small'>#{o.join('')}</ul></fieldset>]
      }
      
      @user.log << %[<fieldset style='height: 20vh; overflow-y: scroll;'><legend><span class='material-icons' style='vertical-align: middle;'>key</span>privledges</legend>#{pri.join('')}</fieldset>]                         
    end
    def contest c
      Contest.new(c)
    end
    def notify u, h={}
      @u = U.new(u)
      @v = JSON.parse(@u.attr[:vapid])
      Redis.new.publish('NOTIFY', "#{u} #{@v} #{h}")
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
    def badge u
      Badge.new(u)
    end
    def banner
      hostname = `hostname`.chomp
      hh = hostname.split('-')
      return hh[0]
    end

    def votes
      v = {}
      VOTES.members.each {|e| v[e] = Vote.new(e).leaderboard }
      return v
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
      @qr = %[#{s}://#{@domain.id}];
    else
      s = 'http'
      @qr = %[https://#{ENV['CLUSTER']}]
    end
    @path = %[#{s}://#{@domain.id}];
    @term = K.new(params[:u]);
    @tree = Tree.new(@domain.id)
    Redis.new.publish("BEFORE", "#{@domain.id} #{@term} #{@tree}")
  }
  
  get('/favicon.ico') { return '' }
  get('/manifest.webmanifest') { content_type('application/json'); erb :manifest, layout: false }
  get('/nomad') { erb :nomad }

  get('/term') { if params.has_key?(:reset); @term.attr.delete(:file); end; erb @term.term }
  
#  get('/man') { erb :man }
  get('/a') { erb :a }
  get('/board') { erb :board }
  get('/onboard') { erb :onboard }
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
    Redis.new.publish('SW', "#{params}")
    @user = U.new(params[:u])
    
    if params.has_key? :subscription
      @user.attr[:vapid] = JSON.generate(params[:subscription])
      notify(params[:u], title: @domain.id, body: 'connected')
    end
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

  get('/zap') do
    content_type :json
    @by = U.new(QRI[params[:u]])
    @user = U.new(QRI[params[:z]])
    @chance = Chance.new(@by.id).zap(@user.id)
    Redis.new.publish('ZAP', "#{@chance}")
    return JSON.generate(@chance)
  end
  
  get('/') {
    @id = id(params[:u]);
    if params.has_key?(:u);
      @user = U.new(QRI[@id]);
      if @user.attr[:xp].to_i < 5 
        @user.log << %[<span class='material-icons' style='vertical-align: middle;'>help</span> get your qrcode above scanned to earn rewards.]
      end
      Bank.mint
      if @user.attr.has_key?(:chance) && @user.attr[:chance] != 'none'
        @chance = Chance.new(@user.id)
      else
        @chance = false
      end
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
    Redis.new.publish('GET.otp', "#{session[:otp]} #{OTP.all}")
    if QRO.has_key?(params[:u]) || IDS.has_key?(params[:u])
      if token(params[:u]) == 'true'
        if params[:t].to_i + ((60 * 60) * 48) <= Time.now.utc.to_i || IDS.has_key?(params[:u])
          ot = []; 6.times { ot << rand(16).to_s(16) }; @otk = ot.join('')
          OTK[params[:u]] = @otk
          @vapid = Webpush.generate_key;
          @id = id(params[:u]);
          @user = U.new(@id);
          privs(@id)
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
          if ENV['BOX'] == 'false'
          w = []; 16.times { w << rand(16).to_s(16) }
          redirect "#{@path}/?w=#{w.join('')}"
          else
            redirect "#{@path}/?auth=0"
          end
        end
      else
        # expired token
        if ENV['BOX'] == 'false'
        w = []; 16.times { w << rand(16).to_s(16) }
        redirect "#{@path}/?w=#{w.join('')}"
        else
          redirect "#{@path}/?auth=0"
        end
      end
    else
      # does not exist
      redirect "#{@path}"
    end
  }


  post('/zap') do
    content_type :json
    @by = U.new(QRI[params[:u]])
    @user = U.new(QRI[params[:z]])
    @chance = Chance.new(@by.id).zap(@user.id)
    Redis.new.publish('ZAP', "#{@chance}")
    return JSON.generate(@chance)
  end
  
  ##
  # remote api
  # NOT WORKING
  post('/box') do
    Redis.new.publish 'BOX.in', "#{params}"
    content_type :json
    if params[:password] == OTK[IDS[params[:username]]]
      params[:u] = IDS[params[:username]]
      params[:q] = QRO[IDS[params[:username]]]
      params[:attr] = U.new(IDS[params[:username]]).attr.all
      token(params[:u], ttl: (((60 * 60) * 24) * 7))
      Redis.new.publish("BOX.auth", "#{@path}")
    end
    Redis.new.publish 'BOX.out', "#{params}"
    return params.to_json
  end

  post('/') do
    Redis.new.publish 'POST', "#{params}"
#    if ENV['BOX'] == 'true' && !params.has_key?(:usr) && !params.has_key?(:cha)
#      uri = URI.parse("https://#{ENV['CLUSTER']}/box")
#      @res = Net::HTTP.post_form(uri, params)
#      j = JSON.parse(@res.body)
#      Redis.new.publish 'POST.BOX', "#{j}"
#      j.each_pair { |k,v| params[k.to_sym] = v }
#    end


    
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
    
    if ENV['BOX'] != 'true' && params.has_key?(:cha) && params[:pin] == Redis.new.get(params[:cha])
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
      ot = []; 64.times { ot << rand(16).to_s(16) }
      OTP[@id] = ot.join('')
      session[:otp] = ot.join('')
      redirect "#{@path}/#{params[:u]}"
    elsif ENV['BOX'] != 'true' && params.has_key?(:usr)
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
      Redis.new.publish('POST.post', "#{params}")
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

      if params.has_key?(:location)
        @by.attr[:latitude] = params[:location][:latitude]
        @by.attr[:longitude] = params[:location][:longitude]
        if @by.id != @user.id
          @user.attr[:rep] = @by.id
          @by.reps << @user.id
          @user.attr[:latitude] = params[:location][:latitude]
          @user.attr[:longitude] = params[:location][:longitude]
        end
      end
      
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
                       
      if params.has_key?(:landing) && LOCKED[@domain.id] == 'false'
        CSS[@domain.id] = params[:css]
        HEAD[@domain.id] = params[:head]                 
        LANDING[@domain.id] = params[:landing]
        FOOT[@domain.id] = params[:foot]
        LOAD[@domain.id] = params[:load]
        INIT[@domain.id] = params[:init]
        OWNERSHIP[@domain.id] = params[:conf][:ownership] || 'sponsor'
        XFER[@domain.id] = params[:conf][:xfer] || 'false'
        LVLS[@domain.id] = params[:conf][:lvls] || 'false'
        SASH[@domain.id] = params[:conf][:sash] || 'false'
        if params[:conf].has_key? :mumble
          MUMBLE[@domain.id] = params[:conf][:mumble]
        end
        if "#{params[:conf][:phone]}".length > 0
          PHONES[@domain.id] = params[:conf][:phone]
        end
        if "#{params[:conf][:admin]}".length > 0
          ADMINS[@domain.id] = params[:conf][:admin]
        end
        if "#{params[:conf][:shares]}".length > 0
          SHARES[@domain.id] = params[:conf][:shares]
        end
        if "#{params[:conf][:exchange]}".length > 0
          EXCHANGE[@domain.id] = params[:conf][:exchange]
        end
        if "#{params[:conf][:procurement]}".length > 0
          PROCUREMENT[@domain.id] = params[:conf][:procurement]
        end
        if "#{params[:conf][:fulfillment]}".length > 0
          FULFILLMENT[@domain.id] = params[:conf][:fulfillment]
        end
        LOCKED[@domain.id] = params[:conf][:lock] || false
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

      if params.has_key?(:magic) && @user.id != @by.id
        l = []
        params[:magic].each_pair { |k,v|
          if "#{v}".length > 0
            @user.attr[k] = v
            l << %[#{k}: #{v}]
          end
        }
        l.each {|e|
          @user.log << %[<span class='material-icons'>info</span> #{e}]
        }
      end
      
      if params.has_key? :config 
        l = []
        params[:config].each_pair { |k,v|
          if "#{v}".length > 0 && v != @by.attr[k] && k != :boss && k != :class && k != :rank
              @by.attr[k] = v
              l << %[#{k}: #{v}]
          end
        }
        if "#{@by.attr[:title]}".length > 0 && "#{@by.attr[:zone]}".length > 0
          t = Time.now.utc
          if @by.attr[:class].to_i > 3
            ttt = "#{t.strftime('%Y')}"
          else
            ttt = "#{t.strftime('%B')} #{t.strftime('%Y')}"
          end
          co = %[Best #{@by.attr[:title]} in #{@by.attr[:zone]} #{ttt}]
          VOTES << co
          Contest.new(co).pool << @by.id
          @by.attr['vote'] = co
          @by.log << %[<span class='material-icons'>emoji_events</span> You are in the "#{co}" contest.]
        end
        
        l.each {|e|
          @by.log << %[<span class='material-icons'>info</span> #{e}]
        }
      end
      
      if params.has_key?(:waypoint)
        Zone.new(@by.attr[:sponsor]).attr[:full] = params[:full]
        @a = TRACKS[request.host][@by.attr[:sponsor]]
        Redis.new.publish "WAYPOINT", "#{params} #{params[:waypoint]}"
        if "#{params[:waypoint][:new][:say]}".length > 0
          v = params[:waypoint][:new]
          if v[:at] == nil
            TRACKS[request.host].mark @by.attr[:sponsor], @by.id, v[:say], v[:for], "#{params[:location][:latitude] || 0},#{params[:location][:longitude] || 0}"
          else
            TRACKS[request.host].mark @by.attr[:sponsor], @by.id, v[:say], v[:for], Zone.new(@by.attr[:sponsor]).attr[:goto]
          end
        end
      end

      if params.has_key?(:track) && params[:track] != ''
        a = params[:track].split('@')
        tp = a[0].split('|')
        tf = a[1].split('#')
        if params[:success] != nil
          @user.attr[:zone] = tf[0]
          @user.badges.incr(tf[1])
          @user.attr.delete(:track)
          @user.log << %[<span class='material-icons' style='color: gold;'>flag</span> You completed you task.]
        end
        Redis.new.publish "WAYPOINT.TRACK", "#{params}"
        learn(request.host, @user.id, @user.attr[:zone] || @by.attr[:sponsor])
        TRACKS[request.host].visit @user.id, @user.attr[:zone] || @by.attr[:sponsor]
        case params[:track]
        when 'auto'
          z = Zone.new(@user.attr[:zone])
          if z.attr[:full].to_i == 5
            zz = @by.attr[:sponsor]
          else
            zz = @user.attr[:zone] || @by.attr[:sponsor]
          end
          w = TRACKS[request.host][zz].waypoints.members.to_a.sample
          p = TRACKS[request.host][zz][w].passwords.keys.to_a.sample
          @user.attr[:track] = { for: 'nomad' }
          @user.log << %[<span class='material-icons' style='color: green;'>flag</span> Go to #{@user.attr[:zone]}. find #{U.new(w).attr[:name]}. The password is: '#{p}']
        when 'fail'
          @user.log << %[<span class='material-icons' style='color: red;'>flag</span> Try again!.]
        else
          @user.attr[:track] = params[:track]
          t = {}; ts = params[:track].split('@')
          tp = ts[0].split('|')
          tf = ts[1].split('#')
          @user.attr[:goto] = Adventure.new(tf[0])[tp[1]].attr[:goto]
          @user.log << %[<span class='material-icons' style='color: blue;'>#{BADGES[tf[1].to_sym]}</span> Go to #{tf[0]}, meet #{U.new(tp[1]).attr[:name]} and say "#{tp[0]}"]
        end
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
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} entered you in the "#{params[:vote]}" contest.]
      end

      if params.has_key?(:contest)
        contest(params[:contest]).votes.incr(@user.id)
        contest(params[:contest]).voters.incr(params[:z])
      end
      
      if params.has_key?(:title) && params[:title] != ''
        TITLES << params[:title]
        @user.titles << params[:title]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} gave you the title "#{params[:title]}".]
      end

      if params.has_key? :zap && params[:zap] == true
        Chance.new(@by.id).zap(@user.id)
      end

      if params.has_key?(:give) && "#{params[:give][:type]}".length > 0
        if @by.id != @user.id
        if params[:give][:of] != nil
          @user.awards.incr(params[:give][:type])
        else
          @user.badges.incr(params[:give][:type])
        end
        end
        @user.log << %[<span class='material-icons'>#{BADGES[params[:give][:type].to_sym]}</span> #{DESCRIPTIONS[params[:give][:type].to_sym]}<ul><li><span>badges:</span> <span>#{@user.badges[params[:give][:type]].to_i}</span></li><li><span>awards:</span> <span>#{@user.awards[params[:give][:type]].to_i}</span></li><li><span>stripes:</span> <span>#{@user.stripes[params[:give][:type]].to_i}</span></li><li><span>boss:</span> <span>#{@user.boss[params[:give][:type]].to_i}</span></li></ul>]
      end
#      if params.has_key? :act
      #        if params[:act] == 'bank'
      if params.has_key? :bank
          Redis.new.publish("OWNERSHIP.bank", "#{params}")
          Bank.wallet[@by.id] = params[:bank][:credit].to_i
          @by.coins.value = params[:bank][:coins].to_i
      end
          #        elsif params[:act] == 'sponsor'
          if params.has_key? :sponsor
          Redis.new.publish("OWNERSHIP.sponsor", "#{params}")
          tf = ((60 * 60) * params[:sponsor][:duration].to_i * params[:sponsor][:timeframe].to_i).to_i;
          pay = (2 ** params[:sponsor][:type].to_i).to_i
          cost = ((params[:sponsor][:units].to_i * pay) * tf).to_i;
          @tree.chan[params[:sponsor][:name]] = @by.attr[:zone] || @tree.attr[:lobby] || request.host
          @tree.link[params[:sponsor][:name]] = @by.attr[:zone] || @tree.attr[:lobby] || request.host
          ZONES << params[:sponsor][:name]
          z = Zone.new(params[:sponsor][:name])
          z.attr[:goto] = "#{params[:location][:latitude]},#{params[:location][:longitude]}"
          z.attr[:owner] = @by.id
          z.attr[:admin] = @by.id
          z.pool << @by.id
          z.attr[:till] = Time.now.utc.to_i + tf;
          z.attr[:pay] = pay;
          z.attr[:cap] = params[:sponsor][:units].to_i;
          z.attr[:budget] = cost
          @by.zones << params[:sponsor][:name]
          Bank.wallet.decr @by.id, cost
          @by.log << %[<span class='material-icons'>cabin</span>#{params[:sponsor][:name]} <span class='material-icons'>savings</span>#{cost}]
          end
          #        elsif params[:act] == 'shares'
          if params.has_key? :shares
          Redis.new.publish("OWNERSHIP.shares", "#{params}")
          if ENV['OWNERSHIP'] == 'franchise'
            @by.attr[:tos] = params[:tos][:terms]
            @by.attr[:agreed] = params[:tos][:agreed]
          end
          if params[:shares][:mode] == 'sell' && Shares.by(request.host)[@by.id].to_i >= params[:shares][:qty].to_i
            Bank.wallet.incr @by.id, params[:shares][:qty].to_i * Shares.cost(request.host)
            Shares.burn @domain.id, @by.id, params[:shares][:qty].to_i
            @by.log << %[-<span class='material-icons'>confirmation_number</span>#{params[:shares][:qty]} +<span class='material-icons'>savings</span>#{params[:shares][:qty].to_i * Shares.cost(request.host)}]
          elsif params[:shares][:mode] == 'buy' && Bank.wallet[@by.id] >= (params[:shares][:qty].to_i * Shares.cost(request.host))
            Bank.wallet.decr @by.id, params[:shares][:qty].to_i * Shares.cost(request.host)
            Shares.mint @domain.id, @by.id, params[:shares][:qty].to_i
            @by.log << %[+<span class='material-icons'>confirmation_number</span>#{params[:shares][:qty]} -<span class='material-icons'>savings</span>#{params[:shares][:qty].to_i * Shares.cost(request.host)}]
          end
          end
#        end
#      end

      if params.has_key? :xfer && params[:xfer] != ''
        Bank.xfer from: @by.id, to: @user.id, amt: params[:xfer]
        @by.log << %[<span class='material-icons'>toll</span> #{params[:xfer]} <-- #{@by.coins.value}]
        @user.log << %[<span class='material-icons'>toll</span> #{params[:xfer]} --> #{@user.coins.value}]
      end
      
      if params.has_key?(:message) && params[:message][:body] != ''
        Redis.new.publish "MESSENGER", "#{params[:message]}"
        to = []
        zone = Zone.new(@by.attr[:sponsor])
        if params[:message].has_key?(:broadcast) && params[:message][:broadcast] == 'users'
          Bank.xfer from: @by.id, amt: zone.users.members.length
          to << [zone.users.members.to_a, zone.pool.members.to_a]
          @p = "star"
        else
          to << zone.pool.members.to_a
          @p = 'stars'
        end
        if OWNERSHIP[request.host] == 'sponsor'
        [to].flatten.each do |e|
          if "#{e}".length > 0
            U.new(e).log << %[<span class='material-icons' style='color: gold; vertical-align: middle;'>#{@p}</span><span style='vertical-align: middle; padding: 0 1% 0 1%; background-color: white; color: black; border-radius: 50px;'><span style=''>#{@by.attr[:name]}</span>@<span style='vertical-align: middle;'>#{@by.attr[:sponsor]}</span></span><span style='vertical-align: middle;'>#{params[:message][:body]}</span>]
          end
        end
        else
          # save png
          # message[pfx] message[body]
          Job.new(@by.id, params[:message][:job]) << params[:message];
        end
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

          if ENV['BOX'] == 'false'
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
                ot = []; 64.times { ot << rand(16).to_s(16) }
                OTP[@by.id] = ot.join('')
                session[:otp] = ot.join('')
                @domain.users.incr(@by.id)
                redirect "#{@path}/#{@by.id}"
              end
            else
              redirect "#{@path}"
            end
          else
            url = "https://#{ENV['CLUSTER']}/box"
            uri = URI(url)
            px = { username: params[:login][:username], password: params[:login][:password], box: Redis.new.get('ONION') }
            res = Net::HTTP.post_form(uri, px)
            j = JSON.parse(res.body)
            if j.has_key?('u')
              token(j['u'], ttl: (((60 * 60) * 24) * 7))
              @id = j['u']
              @by = U.new(@id)
              j['attr'].each_pair { |k,v| @by.attr[k.to_sym] = v }
              IDS[j['username']] = @id
              BOOK[j['username']] = @id
              LOOK[@id] = j['username']
              qrp = j['q']
              QRI[qrp] = IDS[j['username']]
              QRO[IDS[j['username']]] = qrp
              Redis.new.publish('BOX.AUTH', "#{@by} #{j}")
              redirect "#{@path}/#{@by.id}"
            else
              redirect "#{@path}"
            end
          end
        else
          redirect "#{@path}"
        end
      end
      
      if params.has_key? :landing
        redirect "#{@path}/"
      elsif params.has_key? :quick
        redirect "#{@path}/"
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



#Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0 )

def op u
  if "#{u}".length > 0 && IDS.has_key?(u)
    @u = U.new(IDS[u])
    @u.attr[:boss] = 999999999
    @u.attr[:class] = 7
    @u.coins.value ||= 999999999
    @u.zones.members.each do |z|
      if "#{z}".length > 0
      ENV['DOMAINS'].split(' ').each{ |d| learn(d, @u.id, z) }
      learn('localhost', @u.id, z)
      end
    end
  end
end

STATE = Redis::HashKey.new('STATES')

def log(h)
t = h.delete(:topic) || 'NOMAD'
k = h.delete(:key)
Redis.new.publish "#{t}#{k}", "#{h}"
end
log key: '#op', admin: ENV['ADMIN']
op ENV['admin']
LOGINS.keys.each {|e|
  if "#{e}".length > 0
  log key: '.op', login: e
  op e
  end
}

def motd
  log({
    key: '.motd',
    states: STATE.keys,
    logins: LOGINS.keys,
    ips: `hostname -I`.chomp.split(' '),
    hostname: `hostname`.chomp
  })
end

if ENV['NOMAD'] == 'BOOT'
STATE.clear
end

begin
  STATE[:core] = 1
  host = `hostname`.chomp
  if OPTS[:interactive]
    STATE[:interactive] = 1
    Signal.trap("INT") { File.delete("/home/pi/nomad/nomad.lock"); exit 0 }
    Process.detach( fork { APP.run! } )                                    
    Pry.config.prompt_name = :nomad
    motd
    Pry.start(host)
  elsif OPTS[:indirect]
    STATE[:indirect] = 1
    Signal.trap("INT") { puts %[[EXIT][#{Time.now.utc.to_f}]]; exit 0 }
    puts "##### running indirectly... #####"
    Pry.config.prompt_name = :nomad
    motd
    Pry.start(host)
  else
    STATE[:bare] = 1
    motd
    APP.run!
  end
rescue => e
  Redis.new.publish "ERROR", "#{e.full_message}"
  exit
end

