require 'redis-objects'
require 'cinch'

DEBUG = true;

ONION = Redis.new.get("ONION")
HOSTNAME = `hostname`.chomp
if ONION != nil && ONION != ''
  HERE = ONION
elsif ENV['DOMAIN_ROOT'] != nil
  HERE = ENV['DOMAIN_ROOT']
else
  HERE = HOSTNAME + '.local'
end
if m = /(.+)-(.+)/.match(HOSTNAME)
  NICK = m[2]
  CHAN = "#" + m[1]
else
  NICK = HOSTNAME
  CHAN = "#" + HOSTNAME
end

CHANS = Redis::Set.new('CHANS').members.to_a

CHANS << CHAN
CHANS << "#cat"

class Node
  include Redis::Objects
  hash_key :attr
  sorted_set :seen
  sorted_set :state
  def initialize i
    @id = i
  end
  def id; @id; end
  def info
    self.attr[:state]
  end
end

class Hub
  def initialize
    @nodes = {}
  end
  def [] k
    if @nodes.has_key? k
      return @nodes[k]
    else
      return false
    end
  end
  def node k
    @nodes[k] = Node.new(k)
  end
  def drop k
    @nodes.delete k
  end
  def task t
    K.new.instance_eval(t) 
  end
  def info
    o = []
    @nodes.each_pair { |k,v| o << %[#{k}: #{v.info || 'idle'}] }
    return o.join("\n")
  end
end

class Chan
  include Redis::Objects
  list :log
  hash_key :attr
  sorted_set :stat
  def initialize i
    @id = i
  end
  def id; @id; end
  def info
    o = []
    self.stat.members(with_scores: true).to_h.each_pair do |k, v|
      o << %[#{k}: #{v}]
    end
    self.attr.all.each_pair do |k,v|
      o << %[#{k}: #{v}]
    end
    self.log.values.each { |e| o << e }
    return o
  end
end

class K
  
end

HUB = Hub.new

class Cat
  include Cinch::Plugin
  listen_to :channel
  def listen(m)
    if m.channel.name != CHAN
      c = Chan.new(m.channel.name)
      if m.message == 'info'
        c.info.each { |e| Channel(m.channel.name).send(e) }
      elsif /^#/.match(m.message)
        Redis::Set.new("CHANS") << m.message
        Channel(m.channel.name).send("#{Redis::Set.new("CHANS").members.to_a}")
        Channel(m.message).join
      else
        c = Chan.new(m.channel.name)
        c.log << %[[#{m.user.nick}] #{m.message}]
        c.stat.incr(m.user.nick)
        Redis.new.publish "CAT.#{m.channel.name}", "#{m}"
      end
    end
  end
end
class Cluster
  include Cinch::Plugin
  listen_to :connect, :join, :part, :private, :topic
  def listen(m)
    o = []
    if m.events.include? :connect
      Channel(CHAN).send("#{HERE}")
    elsif m.events.include? :join
      if m.user.nick != NICK
      HUB.node m.user.nick
      HUB[m.user.nick].attr[:state] = m.channel.name
      o << HUB.info
      end
    elsif m.events.include? :part
      o << %[#{m.user.nick} -= #{m.channel.name}]
    elsif m.events.include? :private
      o << %[[#{m.user.nick}] #{HUB.task(m.message)}]
    elsif m.events.include? :topic
      o << %[[#{m.channel.name}][#{m.user.nick}] #{HUB.task(m.message)}]
    end
    Channel(CHAN).send(o.join(''))
    Redis.new.publish "CLUSTER", "#{m}"
  end
end


@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = NICK
    c.server = ENV['CLUSTER']
    c.channels = CHANS
    c.plugins.plugins = [Cluster, Cat]
  end
end
@bot.start
