require 'ruby-mud'
require 'redis-objects'
require 'erb'

class Mud
  include Redis::Objects
  hash_key :attr
  sorted_set :inv
  sorted_set :stat
  set :here
  value :pw
  value :owner
  def initialize i
    @id = i
  end
  
  def id; @id; end
end

# Controllers define the action for a menu / sub-game. Eg: Login screen,
# main game, map screen, etc.. By default, the server will start new connections
# in MudServer::DefaultController.
class MudServer::DefaultController
  # on_start will always be called when the user enters a controller.
  # You don't need to use it, but it's there.
  def on_start
    @world = Mud.new('WORLD')
    id = []; 6.times { id << rand(16).to_s(16) }
    @id = id.join('')
    @me = Mud.new(@id)
    Process.detach( fork { Redis.new.subscribe('MUD') { |on| on.message { |c, m| send_text m } }} )
    File.read('/etc/logo').split("\n").each {|e| send_text e }
    void
    prompt
  end

  def login
    Mud.new(@here.id).here.delete(@id)
    u, p = params.split(' ')
    pw = Mud.new(u).pw.value
    if pw == nil
      Mud.new(u).pw.value = p
      send_text "login created."
      @id = u
      @me = Mud.new(@id)
      void
    elsif Mud.new(u).pw.value == p
      @id = u
      @me = Mud.new(@id)
      void
    else
      send_text "login failed."
    end
    prompt
  end

  def allowed_methods
    super + ['login', 'places', 'void', 'here', 'here', 'goto', 'do', 'say', 'own', 'attr']
  end

  def send_error
    send_text "404"
  end
  def quit
    if @world.attr.has_key? @id
      Mud.new(@world.attr[@id]).here.delete(@id)
      @world.attr.delete(@id)
    end
    Mud.new(@here.id).here.delete(@id)
    @session.connection.close
  end
  def say
    Redis.new.publish "MUD", "---> #{@id}@#{@here.id}: " + params
    prompt
  end
  
  def help
    send_text "COMMANDS: #{allowed_methods}"
  end

  def void
    @me = Mud.new(@id)
    if @world.attr.has_key? @id
      Mud.new(@world.attr[@id]).here.delete(@id)
      @world.attr.delete(@id)
    end
    @here = Mud.new('void')
    @here.here << @id
    @me.owner.value = @id
  end

  def places
    @world.here.members.each {|e| send_text "#{e}: #{Mud.new(e).attr[:desc]}" }
    prompt
  end
  
  def own
    pw = @here.pw.value
    if pw == params || pw == nil
      @here.owner.value = @id
      send_text "#{@here.id} owned."
    else
      send_text "failed."
    end
    prompt
  end

  def attr
    if @here.id != 'void' && @here.owner.value == @id
      k, v = params.split(': ')
      @here.attr[k.to_sym] = v
      here
    else
      send_text "you don't own this."
    end
    prompt
  end

  
  def here
    send_text "@#{@world.attr[@id]}: (#{@here.here.members.to_a.join(', ')})"
    ev = []
    @here.attr.all.each_pair { |k,v| if !/^on_/.match(k); send_text "#{k}: #{v}"; else; ev << k.gsub('on_', ''); end }
    send_text "DO: #{ev}"
  end

  def prompt
    send_text "#{@id}@#{@here.id}"
  end
  
  def do
    send_text ERB.new(@here.attr["on_#{params}".to_sym]).result(binding)
    prompt
  end
  
  #Transfer people to a different menu / area using `transfer_to`
  def goto
    @world.here << params
    @world.attr[@id] = params
    Mud.new(@here.id).here.delete(@id)
    @here = Mud.new(params)
    @here.here << @id
    here
    prompt
  end
end

@server = MudServer.new '0.0.0.0', '4321'



@server.start
loop { gets }

