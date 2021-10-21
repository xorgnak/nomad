
# network
ID_SIZE = 16
VAULT_SIZE = 8


FEES = { xfer: 1 }

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
  emergency: 'fire_extinguisher'
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

require 'redis-objects'
require 'sinatra/base'
require 'thin'
require 'json'
require 'slop'
require 'pry'
require 'rufus-scheduler'
require 'twilio-ruby'

CRON = Rufus::Scheduler.new
VOTES = Redis::Set.new("VOTES")
ZONES = Redis::Set.new("ZONES")
TITLES = Redis::Set.new("TITLES")
CHA = Redis::HashKey.new('CHA')
IDS = Redis::HashKey.new('IDS')
BOOK = Redis::HashKey.new('BOOK')
LOOK = Redis::HashKey.new('LOOK')
CODE = Redis::HashKey.new('CODE')
LOCS = Redis::Set.new("LOCS")
ADVENTURES = Redis::Set.new("ADVENTURES")
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
    Twilio::REST::Client.new(ENV['PHONE_SID'], ENV['PHONE_KEY'])
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
      Redis.new.publish "DEBUG.send_sms", "#{t}"
      if ENV['LIVE'] == 'true' && h[:body] != ''
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
def phone
  Phone.new
end

class Adventure
  include Redis::Objects
  set :waypoints
  hash_key :attr
  set :contributors
  sorted_set :stat
  sorted_set :players
  def initialize i
    ADVENTURES << i
    @url = "https://#{OPTS[:domain]}/adventure?a=#{i}"
    @id = i
  end
  def id
    @id
  end
  def create player
    if !self.players.members.include? player
      self.players[player] = 0
      U.new(player).attr.bulk_set({ class: self.attr[:class], pin: self.attr[:pin], adventure: @id })
      U.new(player).log << %[adventure: #{@id}<br>#{self.attr[:desc]}<br>#{self.attr[:instructions]}]
    end
  end
  def progress player

  end
  def html
    o = []
    o << %[<p class='title'><a href='#{@url}'>...</a>#{self.attr[:name]}</p>]
    o << %[<p class='description'>#{self.attr[:description]}</p>]
    o << %[<p class='goal'>#{self.attr[:badge]}</p>]
    return %[<div>#{o.join('')}</div>]
  end
end

class Waypoint
  include Redis::Objects
  hash_key :attr
  sorted_set :stat
  set :contributors
  def initialize i
    @a, @p = i.split(':')
    @url = "https://#{OPTS[:domain]}/waypoint?a=#{@a}&i=#{@p}"
    @id = i
  end
  def id
    @id
  end
  def html
    o = []
    o << %[<p class='title'><a href='#{@url}'>...</a>#{self.attr[:name]}</p>]
    o << %[<p class='location'>#{self.attr[:location]}</p>]
    o << %[<p class='description'>#{self.attr[:description]}</p>]
    o << %[<p class='instructions'>#{self.attr[:instructions]}</p>]
    o << %[<p class='goal'>#{self.attr[:goal]}</p>]
    return %[<div>#{o.join('')}</div>]
  end
end

class AppRTC
  include Redis::Objects
  hash_key :attr
  hash_key :opts
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def link
    a = []; self.opts.all.each_pair {|k,v| a << %[#{k}=#{v}] }
    return %[https://appr.tc/r/#{@id}?hd=true&tt=#{self.attr[:ttl] || 1}&#{a.join('&')}]
  end
  def embeded
    return %[<iframe id='iframe' allow="camera *;microphone *" src='#{link}'></iframe>]
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
  # - [credit] is the amount of credit purchased and inactivated by
  #   a user.  A user may stash their credits and attach them to
  #   an identifier by texting a dollar amount to the number.
  #   The returned id number may be redeemed by texting the id number
  #   to the number.  building credit allows you to qualify for brand
  #   sponsorship.
  #
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
    U.new(h[:from]).coins.decr(h[:amt])
    U.new('BANK').wallet.incr('VAULT', h[:amt])
    Bank.wallet.incr(h[:from], h[:amt])
    U.new(h[:from]).log << %[STASH #{Time.now.utc} #{JSON.generate(h)}]
    return {
      id: Bank.vault(h[:amt].to_i), 
      amt: h[:amt],
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

class CallCenter
  include Redis::Objects
  set :pool
  value :dispatcher
  value :mode
  list :log
  def id; 'calcenter'; end
end
CALL = CallCenter.new()

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
@man.symbol '-b', '--boss', "the admin phone number", default: 'dummy'
@man.int '-p', '--port', "the port we're running on", default: 4567
@man.float '-f', '--frequency', "the radio frequency we're operating on.", default: 462.700
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
  set :public_folder, "public/#{OPTS[:domain]}"
  helpers do
    def code c
      if CODE.has_key? c
        return JSON.parse(CODE[c])
      else
        return false
      end
    end
    def colors b,f,d
      bg = {
        0 => 'darkgrey',
        1 => 'white',
        2 => 'blue',
        3 => 'darkgreen',
        4 => 'red'
      }

      fg = {
        0 => 'lightgrey',
        1 => 'purple',
        2 => 'orange',
        3 => 'yellow',
        4 => 'lightgreen'
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
      ##
      # class: background color. network scope.
      # rank: color. network authority.
      # boss: border color. network responsibility.
      # stripes: border. network privledge.
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
    ##
    # badges: background color. network scope.
    # awards: color. network authority.
    # boss: border color. network responsibility.
    # stripes: border. network privledge.
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
  get('/manifest.webmanifest') { content_type('application/json'); erb :manifest, layout: false }
  get('/man') { erb :man }
  get('/a') { erb :a }
  get('/board') { erb :board }
  get('/adventures') { erb :adventures }
  get('/adventure') { erb :adventure }
  get('/waypoint') { erb :waypoint }
  get('/apprtc') { erb :apprtc }
  get('/radio') { erb :radio }
  get('/call') {
    content_type 'text/xml'
    Twilio::TwiML::VoiceResponse.new do | response |
    case CALL.mode.value
    when 'bossfirst'
      response.dial(number: OPTS[:boss])
      CALL.pool.members.each { |e| response.dial(number: e) }
    when 'dispatcherfirst'
      response.dial(number: CALL.dispatcher.value)
      CALL.pool.members.each { |e| response.dial(number: e) }
    when 'bosslast'
      CALL.pool.members.each { |e| response.dial(number: e) }
      response.dial(number: OPTS[:boss])
    when 'dispatcherlast'
      CALL.pool.members.each { |e| response.dial(number: e) }
      response.dial(number: CALL.dispatcher.value)
    when 'boss'
      response.dial(number: OPTS[:boss])
    when 'dispatcher'
      response.dial(number: CALL.dispatcher.value)
    else
      response.say(message: "Thank you for calling #{OPTS[:domain]}. We are currently closed.  Pease try again later.")
    end
    end.to_s
  }
  get('/sms') {
    Redis.new.publish('SMS', "#{params}")
    if /^\$\d+/.match(params['Body'])
      s =  Bank.stash(from: BOOK[params['From']], amt: params['Body'].gsub('$', ''))
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
  get('/') { @id = id(params[:u]); if params.has_key?(:u); @user = U.new(@id); pool << @id; erb :goto; else erb :landing; end }
  get('/:u') {
    if token(params[:u]) == 'true';
      @id = id(params[:u]);
      @user = U.new(@id);
      pool << @id;
      erb :index
    else
      redirect "https://#{OPTS[:domain]}/?w=#{params[:u]}"
    end
  }
  post('/') do
    Redis.new.publish 'POST', "#{params}"
    if params.has_key?(:file) && params.has_key?(:u)
      fi = params[:file][:tempfile]
      File.open("public/#{OPTS[:domain]}/" + params[:u] + '.img', 'wb') { |f| f.write(fi.read) }
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
      redirect "https://#{OPTS[:domain]}/#{params[:u]}"
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
      phone.send_sms to: '+1' + params[:usr], body: "pin: #{pin.join('')}"
      params.delete(:usr)
      erb :landing
    else
      @id = id("#{params[:u]}#{params[:x]}#{params[:ts]}");
      @by = U.new(@id)
      if params.has_key? :target
        @user = U.new(params[:target]);
      else
        @user = U.new(@id);
      end
      Redis.new.publish 'POST', "#{@user.id}"
      if params.has_key? :admin
        @user.attr.incr(params[:admin].to_sym)
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} increased your #{params[:admin]}.]
        if params[:admin].to_sym == :boss
          pr = []
          case @user.attr[:boss]
          when "1"
            pr = %[vote in contests.]
          when "2"
            @user.attr[:class] = 1
            @user.attr[:rank] = 0
            pr = %[give badge awards.]
          when "3"
            @user.attr[:rank] = 1
            pr = %[certify others badge authority.]
          when "4"
            @user.attr[:class] = 2
            @user.attr[:rank] = 0
            pr = %[invite new users.]
          when "5"
            @user.attr[:rank] = 1
            pr = %[promote others' influence.]
          when "6"
            @user.attr[:rank] = 2
            pr = %[promote others' level, stripes, and pin.]
          when "7"
            @user.attr[:rank] = 3
            pr = %[award titles to others.]
          when "8"
            @user.attr[:class] = 3
            @user.attr[:rank] = 0
            pr = %[send messages.]        
          when "9"
            @user.attr[:rank] = 1
            pr = %[create contests.]
          when "10"
            @user.attr[:class] = 4
            @user.attr[:rank] = 0
            pr = %[create zones.]
          else
            @user.attr[:rank] = 1
            pr = %[do everything.]
          end
          @user.log << %[boss level: #{@user.attr[:boss]}<br>you can now #{pr}] 
        else
          @user.log << %[{params[:admin]}: #{@user.attr[params[:admin].to_sym]}]
        end
      end

      if params.has_key? :code
        if c = code(params[:code])
          if c[:badge];
            @user.badges.incr(c[:badge]);
            @user.log << %[<span class='material-icons'>#{BADGES[c[:badge]]}</span> you have earned the #{c[:badge]}.<br>#{c[:desc]}]
          end
          [:lvl, :rank].each do |e|
            if c[e]; @user.attr.incr(e); end
            @user.log << %[<span class='material-icons'>info</span> +#{e}.]
          end
        else

        end
      end
      
      if params.has_key? :config
        params[:config].each_pair { |k,v|
          if k.to_sym == :boss
            @by.log << %[]
          end
          @by.attr[k] = v
        }
      @user.log << %[<span class='material-icons'>info</span> profile updated.]
      end

      if params.has_key? :waypoint
        Adventure.new(params[:a]).waypoints << "#{params[:a]}:#{params[:i]}"
        Waypoint.new(params[:a] + ':' + params[:i]).contributors << params[:u]
        params[:waypoint].each_pair { |k,v|
          Waypoint.new(params[:a] + ':' + params[:i]).attr[k] = v
        }
        @user.log << %[<span class='material-icons'>info</span> waypoint #{params[:a]}:#{params[:i]} updated.]
      end
      
      if params.has_key? :adventure
        Adventure.new(params[:a]).contributors << params[:u]
        params[:adventure].each_pair { |k,v|
          Adventure.new(params[:a]).attr[k] = v
        }
        @user.log << %[<span class='material-icons'>info</span> adventure #{params[:a]} updated.]
      end

      if params.has_key? :board
        params[:board].each_pair { |k,v|
          Board.new(k).is.value = v
        }
        @user.log << %[<span class='material-icons'>info</span> board updated.]
      end
      
      if params.has_key?(:vote) && params[:vote] != ''
        VOTES << params[:vote]
        Vote.new(params[:vote]).pool << @user.id
        @user.attr['vote'] = params[:vote]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} entered you in #{params[:vote]}.]
      end
      
      if params.has_key?(:zone) && params[:zone] != ''
        ZONES << params[:zone]
        Zone.new(params[:zone]).pool << @user.id
        @user.zones << params[:zone]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} added you to the #{params[:zone]} zone.]
      end
      
      if params.has_key?(:title) && params[:title] != ''
        TITLES << params[:title]
        @user.titles << params[:title]
        @user.log << %[<span class='material-icons'>info</span> #{@by.attr[:name] || @by.id} gave you the title "#{params[:title]}".]
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
        @user.log << %[<span class='material-icons'>#{params[:give][:type]}</span> #{params[:give][:of]} from #{@by.attr[:name] || @by.id} for #{params[:give][:desc]}]
        
      end
      end
      if params.has_key?(:message) && params[:message] != ''
        p = patch(@by.attr[:class], @by.attr[:rank], @by.attr[:boss], @by.attr[:stripes], 0)
        @user.log << %[<span style='#{p[:style]} padding-left: 2%; padding-right: 2%;'>#{@by.attr[:name] || @by.id}</span>#{params[:message]}]
      end
      if params.has_key? :code
        redirect "https://#{OPTS[:domain]}/?u=#{params[:u]}&x=#{params[:x]}&ts=#{params[:ts]}"
      elsif params.has_key? :a
        redirect "https://#{OPTS[:domain]}/adventure?u=#{params[:u]}&a=#{params[:a]}"
      else
        redirect "https://#{OPTS[:domain]}/#{@by.id}"
      end
    end
  end
end

b = OPTS[:port].to_s[3].to_i
Redis::Hashkey.new('DB')[OPTS[:domain]] = b

def db d 
  Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379, :db => Redis::Hashkey.new('DB')[d] )
end

db b

begin
  if OPTS[:interactive]
    Signal.trap("INT") { puts %[[EXIT][#{Time.now.utc.to_f}]]; exit 0 }
    Process.detach( fork { APP.run! } )                                    
    Pry.config.prompt_name = :nomad
    Pry.start(OPTS[:domain])
  else
    APP.run!
  end
rescue => e
  Redis.new.publish "ERROR", "#{e.full_message}"
  exit
end

