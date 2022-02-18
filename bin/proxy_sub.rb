require 'redis-objects'
require 'mqtt'
MQTT::Client.connect('vango.me') do |client|
  # If you pass a block to the get method, then it will loop
  client.get('GREENBOX') do |topic,message|
    m = message.split(' ')
    Redis::HashKey.new('CAMS')[m[0]] = m[1] + ':80/'
    `cd /home/pi/nomad && ./nomad.sh update && sudo reboot`
  end
end
