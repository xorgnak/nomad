# coding: utf-8
@board = GOV[request.host]

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

