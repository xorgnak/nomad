

INFO = {
  name: $0,
  project: "the nomad shell",
  release: 0
}

GEMS = ['json', 'listen', 'redis-objects', 'paho-mqtt', 'slop', 'pry', 'sinatra', 'device_detector', 'twilio-ruby']
DEBS = ['multimon-ng', 'soundmodem']
REQS = ['json', 'listen', 'redis-objects', 'paho-mqtt', 'slop', 'pry', 'sinatra/base', 'device_detector', 'twilio-ruby']


# install dependancies
if ARGF.argv[0] == 'install'
  puts "[INSTALL][INIT][#{Time.now.utc.to_f}]"
  puts "[INSTALL][DEBS][#{Time.now.utc.to_f}]\n" + `su -c 'apt update && apt upgrade -y && apt install -y #{DEBS.join(' ')}'`
  puts "[INSTALL][GEM][#{Time.now.utc.to_i}]" + `su -c 'gem install --no-rdoc --no-ri #{GEMS.join(' ')}'`
end

# load dependancies
REQS.each {|e| require e }



class Here
  include Redis::Objects
  hash_key :uid
  hash_key :ids
  set :banned
  set :admins
  set :usrs
  def initialize c={}
    @conf = c
    @id = c[:domain]
    @bank = Hash.new { |h,k| h[k] = BANK.new(k) }
  end
  def id; @id; end

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
  def phone
    Phone.new
  end
  
  class D
    include Redis::Objects
    sorted_set :referrer
    sorted_set :name
    sorted_set :ver
    sorted_set :os
    sorted_set :os_ver
    sorted_set :dev
    sorted_set :type
    def initialize i
      @id = i
    end
    def id; @id; end
  end
  
  class O
    include Redis::Objects
    
    hash_key :attr
    sorted_set :stat
    sorted_set :priv
    sorted_set :perm
    hash_key :cord

    set :objects
    sorted_set :inventory
    sorted_set :wallet
    
    [ :zones, :grps, :usrs ].each {|e| set e }
    
    def initialize a = nil, i
#      super a
      @id = i
      @fingerprint = D.new(i)
    end
    def id
      @id
    end
    def fingerprint k
      @fingerprint.send(k.to_sym)
    end
    def referrer
      @fingerprint.referrer
    end
  end
  def obj(o); O.new(o); end
  
  class BANK < O
    include Redis::Objects
    list :ledger
    counter :holdings
    def give a, t, m
      self.holdings.decr(a)
      a.times { O.new(t).wallet.incr(@id) }
      self.ledger << m
    end
    def take a, f, m
      self.holdings.incr(a)
      a.times { O.new(f).wallet.decr(@id) }
      self.ledger << m
    end
    def xfer h={}
      p = []; (:A..:Z).each {|e| p << e }
      t = []; 6.times { t << p.sample }
      tx = "#{t.join('')} #{Time.now.utc} #{h[:amt]} #{h[:from]} #{h[:to]}"
      take h[:amt], h[:from], 'T' + tx
      give h[:amt], h[:to], 'G' + tx
      return 0
    end
  end
  def bank(*c)
    if c[0]
      @bank[c[0]]
    else
      @bank[CONF[:money]]
    end
  end

  class ZONE < O
    include Redis::Objects
    set :grps
    set :usrs
    def << u
      usr(u).zones << u
    end
    def rm u
      usr(u).zones.delete(@id)
    end
  end
  def zone(z); ZONE.new(z); end
  
  class LOC < O
    include Redis::Objects
    set :grps
    set :usrs
  end
  def loc(z); LOC.new(z); end
  
  class TAG < O
    include Redis::Objects
    set :grps
    set :usrs
    
    sorted_set :scans
  end
  def tag(t); TAG.new(t); end
  
  class GRP < O
    include Redis::Objects
    set :usrs
    def << u
      usr(u).grps << u
    end
    def rm u
      usr(u).grps.delete(@id)
    end
  end
  def grp(g); GRP.new(g); end
  
  class USR < O
    include Redis::Objects

    value :pin, :expireat => lambda { Time.now + 60 }
    value :token, :expireat => lambda { Time.now + (60 * 60 * 24 * 7) }
    
    sorted_set :promo
    sorted_set :codes
    sorted_set :campaigns
    sorted_set :visits
    
    sorted_set :zones
    sorted_set :types
    sorted_set :classes

    sorted_set :badges
    sorted_set :impacts
    sorted_set :friends
    
    set :grps

    def initialize id
      super
      if !self.attr.has_key? :id
        pool, i = [], [];
        (:A..:Z).each {|e| pool << e }
        (0..9).each {|e| pool << e }
        5.times { i << pool.sample }
        self.attr[:id] = i.join('')
        HERE.ids[i.join('')] = @id
        self.attr['zone'] = 'none'
      end
    end
    
    def challange chk
      p = []; 6.times { p << rand(9) }
      Redis::HashKey.new('chk')[chk] = @id
      self.pin.value = p.join('')
      HERE.phone.send_sms to: @id, body: "pin: #{p.join('')}"
    end
    
    def valid!
      pool, t = [], [];
      (:a..:z).each { |e| pool << e }
      (0..9).each { |e| pool << e }
      32.times { t << pool.sample }
      tok = t.join('')
      HERE.uid[tok] = @id
      self.token.value = tok
    end
    
    def valid?
      if self.token.value
        return self.token.value
      else
        return false
      end
    end
    
    def add *g
      [g].flatten.each { |e| grp(e) << @id }
    end
    def del *g
      [g].flatten.each { |e| grp(e).rm @id }
    end
  end
  def usr(u); USR.new(u); end

  def methods
    [:usr, :grp, :loc, :zone, :obj, :bank]
  end
end

class App
  HEAD = [
    %[<meta name="viewport" content="initial-scale=1, maximum-scale=1">],
    %[<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">],
    %[<!-- <link rel="manifest" href="https://<%= ENV['DOMAIN'] %>/manifest.webmanifest" crossorigin="use-credentials" /> -->],
    %[<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>],
    %[<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/paho-mqtt/1.0.2/mqttws31.js"></script>],
    %[<script src="https://cdn.jsdelivr.net/npm/jquery.qrcode@1.0.3/jquery.qrcode.min.js"></script>],
    %[<script src="https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js"></script>]
  ].join("\n")
  BODY = [
    %[<h1>works.</h1>]
  ].join("\n")
  def initialize(r, p)
    @req, @fingerprint, @redirect = r, {}.merge(p), false
    @app = Hash.new {|h,k| h[k] = []}
    @fingerprint['referrer'] = r.referrer
    @ua = DeviceDetector.new(r.user_agent)
    @fingerprint['ua'] = {
      name: @ua.name,
      ver: @ua.full_version,
      os: @ua.os_name,
      os_ver: @ua.os_full_version,
      dev: @ua.device_name,
      type: @ua.device_type
    }
    Redis.new.publish "App.initialize", "#{@fingerprint} #{p}"
    if p.has_key? :tok
      if HERE.usr(HERE.uid[p[:tok]]).valid?
        @target = 'app'
        @user = HERE.usr(HERE.uid[p[:tok]])
        @zone = HERE.zone(@user.attr['zone'])
        p[:config].each_pair { |k,v| if v != ''; @user.attr[k] = v; end }
        input type: 'hidden', name: 'tok', value: p[:tok]
        input type: 'hidden', name: 'id', value: @user.attr['id']
#        block('div', id: 'main') do
#          input type: 'text', name: 'cmd', placeholder: Time.now.utc
#          button id: 'ok', text: 'OK'
#        end
#        @app[:body] << %[<code>#{@fingerprint}</code>]
        block('nav', style: 'position: fixed; bottom: 0;') do
          button id: 'close', class: 'material-icons ui', text: 'close', style: 'display: none;'
          button id: 'badge', class: 'material-icons func ui', text: 'badge', events: { click: %[$('.body').hide(); $('.func').hide(); $('#close').show(); $('#wrap').show()] }
          button id: 'config', class: 'material-icons func ui', text: 'settings', events: { click: %[$('.body').hide(); $('.func').hide(); $('#close').show(); $('#conf').show()] }
          button id: 'magic', class: 'material-icons func ui', text: 'auto_fix_high', events: { click: %[$('.body').hide(); $('.func').hide(); $('#close').show(); $('#zap').show()] }
        end
      end
    elsif p.has_key?(:auth) && p[:auth] != '' && !HERE.banned.include?(p[:auth])
      @target = 'auth?'
      # auth!
      chk = []; 10.times { chk << rand(9) }
      u = HERE.usr(p[:auth])
      u.challange chk.join('')
      block('div', id: 'main') do
        input type: 'hidden', name: 'chk', value: chk.join('')
        input type: 'text', name: 'pin', placeholder: 'pin'
        button id: 'pin', text: 'pin'
      end
    elsif p.has_key?(:pin) && HERE.usr(Redis::HashKey.new('chk')[p[:chk]]).pin == p[:pin]
      @target = 'auth!'
      # auth?
      HERE.usr(Redis::HashKey.new('chk')[p[:chk]]).valid!
      input type: 'hidden', name: 'tok', value: HERE.usr(Redis::HashKey.new('chk')[p[:chk]]).token.value
      Redis::HashKey.new('chk').delete(p[:chk])
      block('div', id: 'main') { button id: 'ok', text: 'OK' }
    else
      @target = 'index'
      # begin auth cycle
      block('div', id: 'main') {
        input type: 'tel', name: 'auth', placeholder: 'auth'
        button id: 'auth', text: 'auth'
      }
    end
    @fingerprint['ua'].each_pair { |k,v| HERE.obj(@target).fingerprint(k).incr(v) }
    HERE.obj(@target).referrer.incr(@fingerprint['referrer'])
  end
  
  def redirect
    @redirect
  end
  def qrcode h={}
    
  end
  def block t, h={}, &b
    bl = []; h.each_pair { |k,v| bl << %[#{k}='#{v}'] }
    return %[<#{t} #{bl.join(' ')}>#{b.call()}</#{t}>]
  end
  def input h={}
    if h.has_key? :js
      j = j.delete(:js)
    end
    bl = []; h.each_pair { |k,v| bl << %[#{k}='#{v}'] }
    if h[:type] == 'hidden'
      @app[:body] << %[<input #{bl.join(' ')}>]
    else
      @app[:body] << %[<p class='form'><input #{bl.join(' ')}></p>]
    end
    if j; @app[:js] << h[:js]; end
  end
  def button h={}
    if h.has_key? :events
      j = h.delete(:events)
    end
    bl = []; h.each_pair { |k,v| bl << %[#{k}='#{v}'] }
    @app[:body] << %[<button #{bl.join(' ')}>#{h[:text]}</button>]
    if j
      j.each_pair do |k,v|
        @app[:js] << %[$(document).on('#{k}', '##{h[:id]}', function(ev) { ev.preventDefault(); #{v}; })]
      end
    end
  end
  def manifest t
    @user = HERE.usr(HERE.uid[t])
    return ERB.new(%[{
    "theme_color": "#f69435",
    "background_color": "#f69435",
    "display": "fullscreen",
    "scope": "/",
    "start_url": "/?tok=<%= t %>",
    "name": "propedicab.com",
    "short_name": "pedicab",
    "description": "the propedicab.com user interface",
    "icons": [
	{
	    "src": "\/android-icon-36x36.png",
	    "sizes": "36x36",
	    "type": "image\/png",
	    "density": "0.75"
	},
	{
	    "src": "\/android-icon-48x48.png",
	    "sizes": "48x48",
	    "type": "image\/png",
	    "density": "1.0"
	},
	{
	    "src": "\/android-icon-72x72.png",
	    "sizes": "72x72",
	    "type": "image\/png",
	    "density": "1.5"
	},
	{
	    "src": "\/android-icon-96x96.png",
	    "sizes": "96x96",
	    "type": "image\/png",
	    "density": "2.0"
	},
	{
	    "src": "\/android-icon-144x144.png",
	    "sizes": "144x144",
	    "type": "image\/png",
	    "density": "3.0"
	},
	{
	    "src": "\/android-icon-192x192.png",
	    "sizes": "192x192",
	    "type": "image\/png",
	    "density": "4.0"
	}
    ]
}

]).result(binding)
  end
  def html
    return ERB.new(%[<!DOCTYPE html>
<head>
<style>
html { margin: 0; padding: 0; }
body { margin: 0; padding: 0; width: 100vw; height: 100vh; }
#canvas { width: 100%; height: 100%; position: fixed; left: 0; top: 0; z-index: -1; }
form { text-align: center; height: 100%; }
#qrcode > canvas { width: 100%; } 
.ui { 
    background-color: rgba(0,0,0,0.2);
    color: white;
    margin: 2% 3% 2% 3%;
    padding: 0 3% 0 3%;
 }

#{@app[:css].join("\n")}
</style>
#{HEAD}
</head>
<body>

<canvas id='canvas'></canvas>
<form action='/' method='post'>
<% if @app.has_key? :body %>
<%= @app[:body].join("\n") %>
<% else %>
<%= BODY %>
<% end %>
<% if @user %>
<div id='wrap' class='body' style='display: none; width: 100%;'>
<div id="qrcode" style='padding: 2%; border: thick solid black; background-color: white;'></div>
</div>

<div id='conf' class='body' style='display: none;'>
<datalist id='zones'>
<% @user.zones.members.each do |e| %>
<option value='<%= e %>'>
<% end %>
</datalist>
<datalist id='types'>
<% @user.types.members.each do |e| %>
<option value='<%= e %>'>
<% end %>
</datalist> 
<h1><input type='text' name='config[name]' id='name' placeholder='NAME'></h1> 
<h1><input type='text' name='config[pitch]' id='pitch' placeholder='PITCH'></h1>
<h1><input list='zones' name='config[zone]' id='type' placeholder='TYPE'></h1>
<h1><input list='types' name='config[mode]' id='zone' placeholder='ZONE'></h1>
<h1><input type='text' id='social' name='config[social]' value='<%= @user.attr['social'] %>' placeholder='LINK'></h1>
<p>
  <input type='hidden' id='img' name='config[img]' value='<%= @user.attr['img'] %>'>
  <input style='position: fixed; top: -100000px;' type='file' id='file'>
</p>
<button style='padding: 1%; border: thin solid white; height: 20%;' id='pic'>
  <img id='preview' style='height: 100%;' src='<%= @user.attr['img'] %>' alt='click to set image...'>
</button>
</div>

<div id='zap' class='body' style='display: none;'>
<datalist id='classes'>                                                                                                                      
<% @user.classes.members.each do |e| %>
<option value='<%= e %>'>
<% end %>                                                                                                                                    
</datalist>
<datalist id='types'>                                                                                                                      
<% @user.types.members.each do |e| %>                                                                                                        
<option value='<%= e %>'>                                                                                                                    
<% end %>                                                                                                                                    
</datalist>

<datalist id='items'>                                                                                                                        
<% @user.inventory.members.each do |e| %>
<option value='<%= e %>'>                                                                                                                    
<% end %>                                                                                                                                    
</datalist>

<h1 id='boss'>
<input list='classes' name='config[class]' id='class' placeholder='CLASS' value='<%= @user.attr['class'] %>' style='width: 15%;'>
<input list='types' name='config[type]' id='type' placeholder='TYPE' value='<%= @user.attr['type'] %>'>
<input type='number' name='config[lvl]' id='lvl' placeholder='LVL' value='<%= @user.attr['lvl'] %>' style='width: 15%;'>
</h1>

<h1><input list='items' name='give' id='give' placeholder='GIVE'></h1>
<fieldset>
<legend>badge</legend>
<h1><input name='zap[badge]' placeholder='BADGE'></h1>
<% @user.badges.each do |e| %>
<span id='badge-<%= e %>' class='badge'><input type='checkbox' name='badge[<%= e %>]'><span class='material-icons'><%= e %></span></span>
<% end %>
</fieldset>
</div>
<% end %>
</form>
<script>
<% if @user %>
    $('#qrcode').qrcode("https://<%= OPTS[:domain] %>/?u=<%= @user.attr['id'] %>");
    var video = document.createElement("video");
    var canvasElement = document.getElementById("canvas");
    var canvas = canvasElement.getContext("2d");
    // Use facingMode: environment to attemt to get the front camera on phones
    navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function(stream) {
	video.srcObject = stream;
	video.setAttribute("playsinline", true); // required to tell iOS safari we don't want fullscreen
	video.play();
	requestAnimationFrame(tick);
    });
    function tick() {
	if (video.readyState === video.HAVE_ENOUGH_DATA) {
            canvasElement.height = video.videoHeight;
            canvasElement.width = video.videoWidth;
            canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
            var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
            var code = jsQR(imageData.data, imageData.width, imageData.height, { inversionAttempts: 'dontInvert' });
            var dom = /https/g;
            if (code) {
		if (dom.test(code.data)) {
                    var h = {};
                    var o = code.data.split('?');
                    var kv = o[1].split('&');
                    var u;
                    kv.forEach(function(v, i, obj) {
			var oo = v.split('=');
			h[oo[0]] = oo[1]
                    });
                    
		    $('#magic').show();
		}
	    }
        }
        requestAnimationFrame(tick);
    }
  $(document).on('click', '#pic', function(ev) {
  ev.preventDefault();
  $('#file').click();
  });
  $(document).on('change', '#file', function() {
  var u = $('#file')[0].files[0];
  var f = new FileReader();
  f.addEventListener('load', function() {
  $('#preview').attr('src', f.result);
  $('#img').val(f.result);
  }, false);
  if (u) { f.readAsDataURL(u); }
  });    
<% end %>
#{@app[:js].join("\n")}
</script>
</body>
</html>]).result(binding)
  end
end


@man = Slop::Options.new
@man.banner = "usage: #{$0} [options]"
@man.separator "construct"
@man.symbol '-b', '--brand', "our brand", default: :home
@man.symbol '-m', '--money', "our world's money", default: :credit
@man.symbol '-w', '--world', "what we call it", default: :void
@man.separator "app"
@man.symbol '-d', '--domain', "the domain we're running", default: 'localhost'
@man.int '-p', '--port', "the port we're running on", default: 4567
@man.separator "interface"
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.bool '-v', '--verbose', "enable verbose output", default: false
@man.on '--info' do
  puts "[INFO][#{Time.now.utc.to_f}]"
  pp INFO
  exit
end
@man.on '--conf' do
  puts "[CONF][#{Time.now.utc.to_f}]"
  pp CONF
  exit
end
@man.on '--help' do
  puts "[HELP][#{Time.now.utc.to_f}]"
  puts @man
  exit
end

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)
HERE = Here.new(OPTS.to_hash)

class APP < Sinatra::Base
  set :port, OPTS[:port]
  before { @app = App.new(request, params) }
  get('/favicon.ico') {}
  get('/manifest.webmanifest') { @app.manifest params[:tok] }
  get('/') { @app.html }
  post('/') { if @app.redirect; redirect @app.redirect; else; @app.html; end }
  get('/:n') { @app.html }
end

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
  puts "[ERROR] #{e.full_message}"
  exit
end
