require 'redis-objects'
require 'mqtt'
require 'cinch'
require 'pry'

module MUD
  EVENTS = Redis::HashKey.new("MUD:EVENTS")
  ACTIONS = Actions.new
  class Mud
    include Redis::Objects
    set :people
    set :places
    
    def initialize
      @id = "MUD"
      Process.detach( fork { MQTT::Client.connect('localhost') do |c|
                               c.get('#') do |topic, payload|
                                 Redis.new.publish "MQTT", "#{topic} #{payload}"
                               end
                             end
                      })
    end
    def id; @id; end
    def action r, &b
      ACTIONS.act r, b
    end
    def event(m)
      #      Redis.new().publish('DEBUG', "#{m.channel.name}")
      location = place(m.channel.name)
      actor = person(m.user.nick)
      actor.move location.id
      payload = action(m.message)
      Redis.new.publish 'EVENT', "#{location} #{actor} #{payload}"
    end
    def action p
      ACTIONS.action p
    end
    def person p
      self.people << p
      Person.new(p)
    end
    def place p
      self.places << p
      Place.new(p)
    end
  end
  class Actions
    def initialize
      @acts = {}
    end
    def action i
      acts = []
      input = {
        raw: i,
        pair: /(?<key>.+): (?<value>.*)/.match(i),
        words:  i.split(' ')
      }
      acts = []
      @acts.each_pair { |k,v| if k.match(i); acts << v.call(input); end }
      return acts
    end
    def act r, &b
      @acts[r] = b
    end
  end
  class Person
    include Redis::Objects
    value :coord
    hash_key :attr
    def initialize i
      @id = i
      @here = Place.new('0:0:0')
      @here.people << @id 
    end
    def id
      @id
    end
    def move p
      self.coord.value = p
      @here.people.delete(@id)
      @here = Place.new(self.coord.value)
      @here.people << @id
    end
    def event m
      puts "#{m}"
    end
    def here
      @here
    end
  end
  class Place
    include Redis::Objects
    hash_key :attr
    sorted_set :stat
    sorted_set :things
    set :people
    hash_key :thing
    hash_key :events
    def initialize i
      coord = i.split(":")
      @coord = { x: coord[0], y: coord[1], z: coord[2] }
      @id = i
    end
    def id
      @id
    end
    def make t, e, ev={}
      self.thing[t] = e
      self.things.incr(t)
      ev.each_pair {|k,v| EVENTS[ @id + ":" + t + ":" + k ] = v; self.events[t + ":" + k] = v }
    end
    def coord
      @coord
    end
  end
  
  def self.start
    @@MUD = Mud.new()
  end
  def self.event m
    @@MUD.event m
  end
  def self.mud
    @@MUD
  end
end
MUD.start
@mud = MUD.mud
@bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'localhost'
    c.channels = [ '#void', Redis::Set.new('CHANNELS').members.to_a ].flatten
  end
  on(:connect) { }
  on(:message) { |m| MUD.event(m) }
end

begin
  Process.detach( fork { @bot.start } )
  Pry.start
rescue => e
  Redis.new.publish('ERROR', e.message)
end
