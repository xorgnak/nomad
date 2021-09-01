
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
VOTES = Redis::Set.new("VOTES")
ZONES = Redis::Set.new("ZONES")
TITLES = Redis::Set.new("TITLES")
CHA = Redis::HashKey.new('CHA')
IDS = Redis::HashKey.new('IDS')
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
  hash_key :attr
  def initialize i
    @id = i
  end
  def id
    @id
  end
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
  sorted_set :stripes
  sorted_set :badges
  sorted_set :stat
  sorted_set :boss
  set :votes
  set :zones
  set :titles
  hash_key :attr
  counter :coins
  list :log
  value :pin, expireat: 180
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
    def colors b,f,d
      bg = {
        0 => 'darkgrey',
        1 => 'white',
        2 => 'blue',
        3 => 'green',
        4 => 'red'
      }

      fg = {
        0 => 'darkgrey',
        1 => 'purple',
        2 => 'orange',
        3 => 'yellow',
        4 => 'green'
      }
      bd = {
        0 => 'darkgrey',
        1 => 'silver',
        2 => 'gold'
      }
      h =  {
        fg: fg[f.to_i] || 'gold',
        bg: bg[b.to_i] || 'black',
        bd: bd[d.to_i] || 'red'
      }
    end
    def patch b,f,d,p,r
      cl = colors(b,f,d)
      bd = ['none', 'solid', 'dotted']
      s = [%[background-color: #{cl[:bg]};]];
      s << %[color: #{cl[:fg]};]
      s << %[border: thick #{bd[p.to_i] || 'dashed'} #{cl[:bd]};]
      s << %[border-radius: #{r}px;]
      return { style: s.join(' '), colors: cl, }
    end
    def id *i
      if i[0]
        return i[0]
      else
        ii = []; ID_SIZE.times { ii << rand(16).to_s(16) }
        return ii.join('')
      end
    end
    def lvl i
      r, u = [], U.new(i);
      k = ['trip_origin', 'circle', 'adjust', 'stop', 'check_box_outline_blank', 'star', 'star_border', 'stars'];
      u.attr[:lvl].to_i.times {
        r << %[<span class='material-icons pin'>#{k[u.attr[:pin].to_i]}</span>]
      }
      p = patch(u.attr[:class], u.attr[:rank], u.attr[:boss], u.attr[:stripes], 0)
      return %[<h1 id='lvl' style='#{p[:style]}'>#{r.join('')}</h1>]
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
    def badges i
      r, u = [], U.new(i)
      @bgs = u.badges.members(with_scores: true).to_h
      @bss = u.boss.members(with_scores: true).to_h
      @awd = u.awards.members(with_scores: true).to_h
      @stp = u.stripes.members(with_scores: true).to_h
      @bgs.each_pair do |k,v|
        p = patch(v, @awd[k], @bss[k], @stp[k], 1000);
        r << %[<span class='material-icons badge' style='#{p[:style]}'>#{k}</span>]
      end
      return %[<div id='badges'>#{r.join('')}</div>]
    end
  end
  before {}
  get('/favicon.ico') { return '' }
  get('/manifest.webmanifest') { erb :manifest }
  get('/') { @id = id(params[:u]); if params.has_key?(:u); @user = U.new(@id); pool << @id; erb :goto; else erb :landing; end }
  get('/:u') { @id = id(params[:u]); @user = U.new(@id); pool << @id; erb :index }
  post('/') do
    Redis.new.publish 'POST', "#{params}"
    if params.has_key?(:cha) && params[:pin] == Redis.new.get(params[:cha])
      params[:u] = IDS[CHA[params[:cha]]]
      U.new(params[:u]).attr[:phone] = CHA[params[:cha]]
      CHA.delete(params[:cha])
      @id = id(params[:u]);
      @by = U.new(@id)
      @user = U.new(params[:target]);
      erb :index
    elsif params.has_key?(:usr)
      cha = []; 64.times { cha << rand(16).to_s(16) }
      pin = []; 6.times { pin << rand(9) }
      if !IDS.has_key? params[:usr]
        IDS[params[:usr]] = params[:u]
      else
        params[:u] = IDS[params[:usr]]
      end
      CHA[cha.join('')] = params[:usr]
      params[:cha] = cha.join('')
      Redis.new.setex params[:cha], 180, pin.join('');
      erb :landing
    elsif params.has_key? :u
      @id = id(params[:u]);
      @by = U.new(@id)
      @user = U.new(params[:target]);
      
      if params.has_key? :admin
        @user.attr.incr(params[:admin].to_sym)
        @user.log << %[#{@by.attr[:name] || @by.id} increased your #{params[:admin]}.]
      end

      if params.has_key? :config
      params[:config].each_pair { |k,v| @user.attr[k] = v }
      @user.log << %[#{@by.attr[:name] || @by.id} updated your profile.]
      end
      
      if params.has_key?(:vote) && params[:zone] != ''
        VOTES << params[:vote]
        Vote.new(params[:vote]).pool << @user.id
        @user.attr['vote'] = params[:vote]
        @user.log << %[#{@by.attr[:name] || @by.id} entered you in #{params[:vote]}.]
      end
      
      if params.has_key?(:zone) && params[:zone] != ''
        ZONES << params[:zone]
        Zone.new(params[:zone]).pool << @user.id
        @user.zones << params[:zone]
        @user.log << %[#{@by.attr[:name] || @by.id} added you to the #{params[:zone]} zone.]
      end
      
      if params.has_key?(:title) && params[:title] != ''
        TITLES << params[:title]
        @user.titles << params[:title]
        @user.log << %[#{@by.attr[:name] || @by.id} gave you the title "#{params[:title]}".]
      end
      
      if params.has_key? :give
      if params[:give][:type] != nil
        if params[:give][:of] == 'boss'
          @user.boss.incr(params[:give][:type])
        elsif params[:give][:of] == 'stripe'
          @user.stripes.incr(params[:give][:type])
        elsif params[:give][:of] == 'award'
          @user.awards.incr(params[:give][:type])
        elsif params[:give][:of] == 'vote'
          Vote.new(params[:give][:type]).pool << @user.id
        else
          @user.badges.incr(params[:give][:type])
        end
        @user.log << %[#{params[:give][:type]} #{params[:give][:of]} from #{@by.attr[:name] || @by.id} for #{params[:give][:desc]}]
      end
      end
      if params.has_key? :message
        m = [%[<span style='margin-left: 1%; margin-right: 1%;'>]]
        m << %[<span style='color: gold;'>\[</span>]
        m << %[<span style='color: white;'>#{@by.attr[:name] || @by.id}</span>]
        m << %[<span style='color: gold;'>\]</span></span>]
        m << %[<span style='color: lightgrey;'>#{params[:message]}</span>]
        @user.log << m.join('')
      end
      erb :index
    else
      redirect '/'
    end
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

