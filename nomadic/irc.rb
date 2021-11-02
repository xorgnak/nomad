require 'cinch'
require 'redis-objects'

class Handler
  def initialize m
    @m, @r = m, []
    Redis.new.publish('IRC', "#{m}")
    @input = @m.message
    if x = /^(.+): (.*)/.match(@input)
      @words = [ x[1], x[2].split(' ') ].flatten
    else
      @words = @input.split(' ')
    end
    if [ :run, :do, :get, :set ].include? @words[0].to_sym
      @r << %[#--------------#]
      @r << %[# #{@words}]
      @r << %[#--------------#]
    end
  end
  def reply
    @r
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "localhost"
    c.channels = ["#op"]
    c.nick = 'cat'
  end

  on :message do |m|
    @h = Handler.new(m)
    if @h.reply.length > 0;
      @h.reply.each {|e| m.reply e }
    end
  end
end

bot.start
