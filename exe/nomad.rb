# coding: utf-8


require 'em-websocket'


load 'lib/requires.rb'
load 'lib/opts.rb'
load 'lib/env.rb'

load 'lib/libs.rb'


$ch = EM::Channel.new
Process.detach( fork {
EventMachine.run do

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
    @board = GOV[request.host]
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
  get('/onboarding') { erb :obboarding }
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
  get('/onion') { @user = U.new(params[:u]); erb :onion }
  get('/dev') { @user = U.new(params[:u]); erb :dev }
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
         EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
         #settings.sockets.each{ |s| s.send(msg); }
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
        if /.*:.*/.match(@user.id)
          u = @user.id.split(':')
          notify(u[0], title: %[u[2]], body: %[#{params[:track]}])
        end
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

      if params.has_key?(:zone) && "#{params[:zone]}".length > 0 
        @user.zones << params[:zone]
        Zone.new(params[:zone]).users << @user.id
        @board.zones << params[:zone]
        @board.users << @user.id
        @board.pool << @user.id
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
##
class Pipe
  require Redis::Objects
  def initialize u, &b
    @id = "PIPE:#{u}"
    Redis.new.subscribe(@id) do |on|
      on.message do |channel, message|
        j = JSON.parse(msg)
        @user = U.new(j['u'])
        b.call(j)
      end
    end
  end
  def << m
    Redis.new.publish @id, m
  end
  def id; @id; end
end
class Hole
  require Redis::Objects
  def initialize &b
    @id = "HOLE"
    Redis.new.subscribe(@id) do |on|
      on.message do |channel, message|
        j = JSON.parse(msg)
        @user = U.new(j['u'])
        b.call(j)
      end
    end
  end
  def push h
    Redis.new.publish @id, JSON.generate(h)
  end
  def id; @id; end
end

Process.detach( fork {
EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |ws|

  @hole = Hole.new do |h|
    $ch.push(JSON.generate(h))
  end
  @pipe = Hash.new {|h,k| h[k] = Pipe.new(k) { |hh| ws.send(JSON.generate(hh))  }}
  ws.onopen {
    sid = $ch.subscribe { |msg|
      j = JSON.parse(msg)
      @user = U.new(j['u'])
      @pipe[j['u']].push j
    }
    
    ws.onmessage { |msg|
      j = JSON.parse(msg)
      @u = U.new(j['u'])
      @pipe[j['u']].push j
    }
    
    ws.onclose {
      $ch.unsubscribe(sid)
    }
  }
  
end } )
Signal.trap("INT") { File.delete("/home/pi/nomad/nomad.lock"); exit 0 }
Process.detach( fork { APP.run! } )
end
} )                       
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
  useradd u
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
        economy: Shares.market,
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
    Pry.config.prompt_name = :nomad
    motd
    Pry.start(host)
  elsif OPTS[:indirect]
    STATE[:indirect] = 1
    puts "##### running indirectly... #####"
    Pry.config.prompt_name = :nomad
    motd
    Pry.start(host)
  else
    STATE[:bare] = 1
    motd
  end
rescue => e
  Redis.new.publish "ERROR", "#{e.full_message}"
  exit
end

