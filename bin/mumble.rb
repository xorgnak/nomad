require 'pry'
require 'redis-objects'
require 'erb'

load 'bin/colorize.rb'

class Mum
  
  def initialize h={}
    @chans = []
    @links = []
    @banner = h[:banner] || "welcome to #{ENV['DOMAIN']}"
    @ch = h[:ch]
    @pw = h[:pw]
    @port = h[:port]
    h[:chan].each_pair { |k,v| @chans << mk_room(k, v) }
    h[:link].each_pair { |k,v| @links << mk_link(k, v) }
  end
  def mk_link f, t
    return %[{                                                                                                                                          
        source = "#{f}";                                                                                                                        
        destination = "#{t}";                                                                                                                
}]      
  end
  
  def mk_room dir, *p
    if p[0].length > 0
      pp = p[0]
    else
      pp = ENV['DOMAIN']
    end
    if p[1]
      if p[1].to_sym == :silent
        pe = 'silent = true;'
      elsif p[1].to_sym == :noenter
        pe = 'noenter = true;'
      end
    end
    
    return %[{                                                                                                                                              
               name = "#{dir}";                                                                                                                   
               parent = "#{pp}";
               description = "";                                                                                                                            
               #{pe}                                                                                                                              
             }
]
  end
  
  def conf
    c = %[
max_bandwidth = 48000;
welcometext = "#{@banner}";
certificate = "/etc/umurmur/cert.crt";
private_key = "/etc/umurmur/key.key";
ca_path = "/path/to/ca/certificates/";  # Location of CA certificate. Relevant for OpenSSL only.

password = "";
admin_password = "#{@pw}";   # Set to enable admin functionality.
ban_length = 0;            # Length in seconds for a ban. Default is 0. 0 = forever.
enable_ban = false;        # Default is false
banfile = "banfile.txt";   # File to save bans to. Default is to not save bans to file.
sync_banfile = false;      # Keep banfile synced. Default is false, which means it is saved to at shutdown only.
allow_textmessage = true;  # Default is true
opus_threshold = 100;      # Required percentage of users that support Opus codec for it to be chosen
show_addresses = false;     # Whether to show client's IP addresses under user information
max_users = 100;
bindport = #{@port};

channels = ( {
               name = "#{ENV['DOMAIN']}";
               parent = "";
               description = "";
               noenter = true;
             },
             {
               name = "#{@ch}";
               parent = "#{ENV['DOMAIN']}";
               description = "";
             },
             {
               name = "Quiet";
               parent = "#{ENV['DOMAIN']}";
               description = "Silent channel";
               silent = true;
               position = -1; # Will appear before 'lobby' channel in the client's channel tree
             }
             <% if @chans.length > 0 %><%= ",\n" + @chans.join(',') %><% end %>
           );
# Channel links configuration.
channel_links = (
                 <%= @links.join(',') %> 
                );

# The channel in which users will appear in when connecting.
# Note that default channel can't have 'noenter = true' or password set
default_channel = "#{@ch}";
]
    return ERB.new(c).result(binding)
  end
  def save
    File.open("mumble/#{ENV['DOMAIN']}.conf", 'w') {|f| f.write(conf) }
  end
end

class Tree
  include Redis::Objects
  hash_key :attr
  hash_key :chan
  hash_key :link
  def initialize i
    @id = i
  end
  def id; @id; end
  def mum
    Mum.new pw: self.attr[:pw] || ENV['MUMBLE_PW'] || '', ch: self.attr[:lobby] || ENV['MUMBLE_LOBBY'] || 'PUBLIC', port: ENV['MUMBLE'], chan: self.chan.all, link: self.link.all
  end
end

if ARGF.argv[0] == '-i'
  @tree = Tree.new(ARGF.argv[1])
  o,h = [], Hash.new {|h,k| h[k] = [] }
  puts "[".yellow + "TREE".blue + "]".yellow + "#{@tree.id}"
  puts "[map]".yellow
  @tree.link.all.each_pair { |f,t|
    @tree.chan.all.each_pair { |c,p|
      p = @tree.id if p.length == 0
      if c == t
        h["#{p}/#{c}"] << "<-- /#{f} "
      elsif c == f
        h["#{p}/#{c}"] << "-->"
      else
        h["#{p}/#{c}"] << ""
      end
    }
  }
  h.each_pair {|k,v| o << "#{k} #{v.join('')}" }
  o.each {|e| puts "#{e}" }
  puts "[usage]".yellow
  puts "@tree.chan[:channel_name] = :parent_chan_name | :silent :noenter"
  puts "@tree.link[:source_channel_name] = :sink_channel_name"
  puts "@tree.attr[:pw] = 'admin password'"
  puts "@tree.attr[:lobby] = :lobby_channel_name"
  puts "@tree.attr[:banner] = 'server welcome text'"
  puts "@tree.mum.save"
  puts "# exit to quit...".green
  puts "## REBOOT TO LOAD CHANGES".red
  Pry.start
else
  @t = Tree.new(ARGF.argv[0])
  @m = Mum.new(pw: @t.attr[:pw] || ENV['MUMBLE_PW'] || '',
               ch:  @t.attr[:lobby] || ENV['MUMBLE_LOBBY'] || 'PUBLIC',
               port: ENV['MUMBLE'],
               chan: @t.chan.all,
               link: @t.link.all,
               banner: @t.attr[:banner]
              )
  @m.save
end

