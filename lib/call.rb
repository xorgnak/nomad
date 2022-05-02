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