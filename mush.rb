require 'redis-objects'
require 'mqtt'
require 'cinch'
require 'pry'

class Here

  def initialize

  end
  def id; "HERE"; end
  def event m
    Redis.new.publish("DEBUG.here", "#{m}")
  end
  def auth u,p
    Redis.new.publish("DEBUG.auth", "#{u} #{p}")
  end
end

HERE = Here.new
BOT = Cinch::Bot.new do
  configure do |c|
    c.server = 'localhost'
    c.nick = 'cat'
    c.channels = [ '#void', Redis::Set.new('CHANNELS').members.to_a ].flatten
  end
  on(:connect) { Redis.new.publish("DEBUG.irc.conect", "#{HERE}") }
  on(:message) { |m| HERE.event(m) }
  on(:message, /^auth (.+)/) { |m, k| User(m.user.nick).send(HERE.auth(m.user.nick, k)) }
  on(:message, /^call (.+)/) { |m, k| BOT.join(k) }
end

begin
  Process.detach( fork { BOT.start } )
  if ARGF.argv[0] == '-i'
    Pry.start
  end
rescue => e
  Redis.new.publish('ERROR', e.message)
end
