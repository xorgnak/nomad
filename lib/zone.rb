class Zone
  include Redis::Objects
  set :pool
  set :users
  hash_key :jobs
  hash_key :items
  hash_key :attr
  counter :coins
  set :waypoints
  set :adventures
  set :urls
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def pay a, *u
    [u].flatten.each {|e| Bank.xfer to: e, from: @id, amt: a }
  end
  def rm!
    Bank.xfer from: @id, amt: self.coins.value
    Redis.new.keys.each { |e| if /#{@id}/.match(e); Redis.new.del(e); end }
  end
end