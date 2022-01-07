require 'redis-objects'
require 'cinch'
require 'pry'

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

class Bot
  STATE = Redis::HashKey.new("STATE")
  class Node
    include Redis::Objects
    hash_key :attr
    def initialize i
      @id = i
    end
    def id; @id; end
  end
  class Cmd
    def initialize m
      @node = Node.new(m.user.nick('_',  ''))
      @node.attr[:input] = m.message
#      mm = m.message.split(" ").map { |e| e.to_sym }
      r = self.instance_eval(m.message)
      @node.attr[:output] = r
#      Redis.new.publish("DEBUG", "#{m.message} -> #{@node.attr.all}")
      return "#{@node.attr.all}"
    end
  end
  def initialize
    Redis.new.publish "BOT", "#{CHAN}.#{NICK}.#{HERE}"
    @bot = Cinch::Bot.new do
      configure do |c|
        c.nick = NICK
        c.server = ENV['DOMAIN_ROOT']
        c.channels = ["#bot" , CHAN]
      end
      on(:connect) do |m|
        ["#bot", CHAN].each do |e|
          Channel(e).send("at: #{HERE}")
        end
      end
      on(:topic) do |m|
        if m.channel.name == CHAN
          Channel(CHAN).send("topic: #{Cmd.new(m)}")
        end
      end
      on(:channel) do |m|
        if /.+: .*/.match(m.message)
          mm = m.message.split(": ")
          n = Node.new(m.user.nick.gsub('_', ''))
          n.attr[mm[0]] = mm[1]
          x = "#{n.attr.all}"
        else
          STATE[m.user.nick.gsub('_', '')] = m.message
          x = "#{STATE.all}"
        end
        Channel(CHAN).send("#{x}")
      end
      on(:private) do |m|
        Channel(CHAN).send( "priv: #{Cmd.new(m)}")
      end
    end
  end
  def bot
    @bot
  end
end
BOT = Bot.new
BOT.bot.start
