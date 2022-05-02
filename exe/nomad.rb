load 'lib/requires.rb'
load 'lib/opts.rb'
load 'lib/env.rb'

load 'lib/libs.rb'

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
        pri << %[<fieldset style='margin: 0; padding: 0;'><legend><span><span class='material-icons' style='vertical-align: middle; font-size: small; margin: 0;'>#{PINS[k]}</span><span>class #{k}</span></span></legend><ul style='font-size: small'>#{o.join('')}</ul></fieldset>]
      }
      
      @user.log << %[<fieldset style='padding: 0; border-bottom: none; border-left: none; border-right: none;'><legend onclick='$("#privs").toggle();' style='border: thin outset white; border-radius: 50px;'><span class='material-icons' style='vertical-align: middle;'>key</span>class #{@user.attr[:class]}</legend><div id='privs' style='display: none;'>#{pri.join('')}</fieldset>]                         
    end
    def contest c
      Contest.new(c)
    end
    def notify u, h={}
      @u = U.new(u)
      @v = JSON.parse(@u.attr[:vapid])
      if @v != nil
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
    load 'lib/call.rb'
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
#      if @user.attr[:xp].to_i < 5 
#        @user.log << %[<span class='material-icons' style='vertical-align: middle;'>help</span> get your qrcode above scanned to earn rewards.]
#      end
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
    load 'lib/post.rb'
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

