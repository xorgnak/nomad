require 'em-websocket'
require 'redis-objects'
require 'sinatra/base'
require 'sinatra-websocket'
require 'thin'
require 'json'
require 'slop'
require 'pry'
require 'rufus-scheduler'


CRON = Rufus::Scheduler.new

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

class K
  HELP = %[<h1><%= `hostname` %></h1>
<h3><%`date`%></h3>
<h3><%= `uname -a`%></h3>
this is only a test.]
  include Redis::Objects
  def initialize i
    @id, @html = i, []
  end
  def puts e
    return "#{e}"
  end
  def edit f
    return %[<input type='hidden' name='filename' value='#{f}'><textarea name='file'>#{File.read(Dir.pwd + '/' + f)}</textarea>]
  end
  def help
    ERB.new(HELP).result(binding)
  end
  def button t, h={}
    a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] }
    return %[<button #{a.join(' ')}>#{t}</button>]
  end
  def input h={}
    a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] }
    return %[<input #{a.join(' ')}>]
  end
  def eval e
    begin
      if e == ''; e = 'help'; end
      e.split(';').each do |each|
        @html << "#{self.instance_eval(each)}".gsub("\n", '<br>')
      end
    rescue => e
      @html << "[#{e.class}] #{e.message}"
    end
  end
  def html
    @html.join('')
  end
  def id
    @id
  end
end

class App < Sinatra::Base
INDEX = %[<form id='form' action='/' method='post'>
<input type='text' id='cmd' name='cmd'>
<button id='snd'>\<\<</button>
<div id='output'><%= @app.html %></div>
</form><script></script>
]
  
  set :port, OPTS[:port]
  set :bind, '0.0.0.0'
  set :server, 'thin'
  set :public_folder, '/home/pi/'
  helpers {
    def index; ERB.new(INDEX).result(binding); end
  }
  before {
    Redis.new.publish(request.request_method, "#{params}");
    @app = K.new(params[:id] || 'app')
  }
  get('/') { @app.eval('help'); index }
  post('/') { @app.eval(params[:cmd]); index }
end
App.run!



