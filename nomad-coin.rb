
# network
ID_SIZE = 16
VAULT_SIZE = 8

FEES = { xfer: 1 }

BADGES = ['backpack', 'campaign', 'coronavirus', 'directions', 'explore', 'bike_scooter', 'directions_bike', 'home_repair_service', 'restaurant', 'fastfood', 'local_cafe', 'local_bar', 'local_pizza', 'set_meal', 'celebration', 'nightlife', 'sports_bar', 'outdoor_grill', 'smoking_rooms', 'medical_services', 'offline_bolt', 'highlight', 'palette', 'night_shelter', 'radio', 'local_fire_department', 'fire_extinguisher', 'biotech', 'festival', 'carpenter', 'child_friendly', 'self_improvement', 'memory', 'spa', 'loyalty', 'support_agent', 'local_shipping', 'two_wheeler', 'drive_eta', 'airport_shuttle', 'agriculture', 'carpenter', 'plumbing', 'history_edu', 'construction', 'speed', 'sports_score', 'tour']

require 'redis-objects'
require 'sinatra/base'
require 'thin'
require 'json'
require 'slop'
require 'pry'
require 'rufus-scheduler'

CRON = Rufus::Scheduler.new

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

module Bank
  ##
  #
  def self.wallet u
    Redis::SortedSet.new("wallet:#{u}")
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
    U.new(h[:from]).coins.decr(h[:amt])
    U.new('BANK').wallet.incr('VAULT', h[:amt])
    Bank.wallet(h[:from]).incr(h[:amt])
    a = Bank.vault h[:amt].to_i
  end
  ##
  # recover stashed coins 
  def self.recover h={}
    a = Bank.vaults[h[:id]].to_i
    Bank.vaults.delete(h[:id])
    U.new('BANK').wallet.decr('VAULT', a)
    U.new(h[:to]).coins.incr(a)
    Bank.wallet(h[:to]).decr(h[:amt])
  end
  def self.xfer h={}
    b = U.new('BANK')
    f = U.new(h[:from] || 'BANK')
    if f.coins.value >= h[:amt]
    f.wallet.decr(h[:type] || :gp, h[:amt]|| 0)
    f.coins.decr(h[:amt])
    t = U.new(h[:to] || 'BANK')
    if h.has_key? :in
      d = h[:in]
    elsif h.has_key? :at
      d = timer(h[:at])
    else
      d = 0
    end
    fee = (("#{d}".length + 1 ) * FEES[:xfer]).to_i
    f.coins.decr(fee)
    b.coins.incr(fee)
    CRON.at(Time.now + d) do
        t.wallet.incr(h[:type] || :gp, h[:amt] || 0)
        t.coins.incr(h[:amt])
      end
    return true
    else return false
    end
  end
end

class U
  include Redis::Objects
  sorted_set :wallet
  sorted_set :awards
  sorted_set :badges
  sorted_set :stat
  sorted_set :boss
  hash_key :attr
  counter :coins
  def initialize i
    @id = i
  end
  def id
    @id
  end
end

@man = Slop::Options.new
@man.symbol '-d', '--domain', "the domain we're running", default: 'localhost'
@man.int '-p', '--port', "the port we're running on", default: 4567
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.on '--help' do
  puts "[HELP][#{Time.now.utc.to_f}]"
  puts @man
  exit
end

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)

class APP < Sinatra::Base
  set :port, OPTS[:port]
  set :bind, '0.0.0.0'
  set :server, 'thin'
  helpers do
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
    def badges u

    end
  end
  before {}
  get('/favicon.ico') { return '' }
  get('/') { @id = id(params[:u]); pool << @id; erb :index }
  post('/') do
    Redis.new.publish 'POST', "#{params}"
    @id = id(params[:u]);

    if params.has_key? :config
      params[:config].each_pair { |k,v|  }
    end
    if params.has_key? :magic
      params[:magic].each_pair { |k,v|  }
    end
    
    erb :index
  end
end

begin
  if OPTS[:interactive]
    Signal.trap("INT") { puts %[[EXIT][#{Time.now.utc.to_f}]]; exit 0 }
    Process.detach( fork { APP.run! } )
#    Process.detach( fork { BOT.start } )                                       
    Pry.config.prompt_name = :nomad
    Pry.start(OPTS[:domain])
  else
    APP.run!
  end
rescue => e
  Redis.new.publish "ERROR", "#{e.full_message}"
  exit
end

