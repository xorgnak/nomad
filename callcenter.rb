require 'redis-objects'
require 'sinatra/base'
require 'thin'
require 'json'
require 'slop'
require 'pry'
require 'rufus-scheduler'
require 'twilio-ruby'

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

class CallCenter
  include Redis::Objects
  value :oncall
  hash_key :pool
  hash_key :pager
  list :log
  def id; 'calcenter'; end
  def add u
    a = []; 4.times { a << rand(9) }
    self.pool[a.join('')] = u
    self.pager[u] = a.join('')
  end
end

CALL = CallCenter.new()

class Phone
  def twilio
    Twilio::REST::Client.new(ENV['PHONE_SID'], ENV['PHONE_KEY'])
  end
  def send_sms h={}
    to = []
    case OPTS[:mode]

    when 'all'
      to = CALLp.pager.keys
    when 'admin'
      to = [CALL.oncall.value]
    else
      to = [OPTS[:admin]]
    end
    to.each do |t|
      Redis.new.publish "DEBUG.send_sms", "#{t}"
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

@man = Slop::Options.new
@man.symbol '-d', '--domain', "the domain we're running", default: 'localhost'
@man.symbol '-b', '--boss', "the admin phone number", default: 'dummy'
@man.int '-p', '--port', "the port we're running on", default: 4567
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.on '--help' do
  puts "[HELP][#{Time.now.utc.to_f}]"
  puts @man
  exit
end

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)


class CallCenter
  include Redis::Objects
  set :pool
  value :dispatcher
  value :mode
  list :log
  def id; 'calcenter'; end
end
CALL = CallCenter.new()


class APP < Sinatra::Base
  
  configure do

  end
  get('/') {}
  post('') {}
  get('/call') {}
  get('/sms') {}
  
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
