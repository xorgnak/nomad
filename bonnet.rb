require 'pi_piper'
require 'redis-objects'
require 'pry'
require 'json'
puts "Press the switch to get started"

#pin = PiPiper::Pin.new(:pin => 4, :direction => :in, :pull => :up)

@btns = Hash.new { |h,k| h[k] = false }

MENU = [
  {
    name: "info",
    items: [
      {cpu: %[<%= `cat /proc/cpuinfo` %>]},
      {mem: %[<%= `cat /proc/meminfo` %>]}
    ]
  },
  {
    name: "music",
    items: []
  },
  {
    name: "lights",
    items: []
  },
  {
    name: "pager",
    pager: []
  }
]

@x, @y, @z, @a, @b = 0, 0, 0, 0, 0
@t = { boot: Time.now.utc.to_f, now: Time.now.utc.to_f, last: { 4 => 0, 5 => 0, 6 => 0 }, ago: { 4 => 0, 5 => 0, 6 => 0 },  }
def menu p
  @t[:now] = Time.now.utc.to_f
  if p.pin == 17
    if @x < 15
      @x += 1
    end
  elsif p.pin == 22
    if @x > 0
      @x -= 1
    end
  elsif p.pin == 27
    if @y < 15
      @y += 1
    end
  elsif p.pin == 23
    if @y > 0
      @y -= 1
    end
  elsif p.pin == 4
    @x, @y, @z, @a, @b = 0,0,0,0,0
    @t[:ago][4] = @t[:now] - @t[:last][4]
    @t[:last][4] = Time.now.utc.to_f
elsif p.pin == 5
if @a < 7
  @a += 1
end
if @z < 15
  @z += 1
end
  @t[:ago][5] = @t[:now] - @t[:last][5]
  @t[:last][5] = Time.now.utc.to_f
elsif p.pin == 6
  if @b < 7
    @b += 1
  end
  if @z > 0
    @z -= 1
  end
  @t[:ago][6] = @t[:now] - @t[:last][6]
  @t[:last][6] = Time.now.utc.to_f
  end
  

  display
end

def display
  h = {
    coords: { x: @x, y: @y, z: @z, a: @a, b: @b },
    timings: @t
  }
  Redis.new.publish('bonnet', JSON.generate(h))
  new_color = "#{@x.to_s(16)}#{@y.to_s(16)}#{@z.to_s(16)}"
  last_color = Redis.new.get('BONNET')
  if /000$/.match(last_color) && new_color == '000'
    Redis.new.set('INPUT', "#{last_color} #{new_color}")
    colors = "#{new_color}"
  else
    colors = "#{last_color} #{new_color}";
  end
  Redis.new.set('BONNET', colors)
end

PiPiper.after(:pin => 4, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 5, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 6, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 27, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 23, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 17, :pull => :up, :goes => :low) { |pin| menu(pin) }
PiPiper.after(:pin => 22, :pull => :up, :goes => :low) { |pin| menu(pin) }

Process.detach( fork { PiPiper.wait } )
Pry.start
