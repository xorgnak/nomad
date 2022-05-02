class K
  HELP = [
    %[<style>#help li code { border: thin solid black; padding: 1%; }</style>],
    %[<ul id='help'>],
    %[<li><code>cd :name</code><span>focus on a campaign.</span></li>],
    %[</ul>],
    %[<ul>],
    %[<li><button disabled>FS</button> edit the campaign files.</li>],
    %[<li>the campaign index files are the main focus of the campaign.</li>],
    %[<li>adding other files adds pins, app elements, and sub-campaign configuratons.</li>],
    %[</ul>]
  ].join('')
  TERM = [%[<style>#ui { width: 100%; text-align: center; } #ui > input { width: 65%; }],
          %[ #ls { height: 80%; overflow-y: scroll; font-size: small; }],
          %[ #ui > * { vertical-align: middle; }],
          %[ #ui > textarea { height: 80%; width: 100%; }<%= css %></style>],
          %[<h1 id='ui'>],
          %[<a href='/<%= @id %>' class='material-icons' style='border: thin solid black;'>home</a>],
          %[<button type='button' onclick='$("#ls").toggle();'>FS</button>],
          %[<input name='cmd' placeholder='<%= `hostname` %>'>],
          %[<button type='submit' class='material-icons'>send</button></h1>],
          %[<fieldset id='ls' style='display: none;'><legend><a href='/<%= QRO[id] %><%= pwd %>'><%= pwd %></legend></a><%= ls  %></fieldset>],
          %[<div id='output'><%= html %></div>],
          %[#{HELP}],
          %[<script>$(function() { <%= self.scripts.values.join('; ') %>; });</script>]].join('')
  include Redis::Objects
  list :content
  list :scripts
  list :styles
  value :dir
  hash_key :attr
  def initialize(i);
    @id = i;
  end
  def ls
    o = []
    "#{`ls -lha #{self.dir.value}`}".split("\n").each {|e|
      skip = false
      f = e.split(' ')[-1]
      if /^d/.match(e)
        if /\.$/.match(e) || /\.\.$/.match(e)
          b = %[]
          skip = true
        else
          b = %[<button class='material-icons' name='cmd' value='cd("#{f}")'>folder</button>]
        end
      elsif /^total/.match(e)
        b = %[]
        skip = true
      else
        if /.markdown/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>post_add</button>]
        elsif /.erb/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>article</button>]
        elsif /.json/.match(e)
          b = %[<button class='material-icons' name='cmd' value='edit("#{f}")'>list</button>]
        end
      end
      if skip == false
        o << %[<p>#{b} #{e}</p>]
      end
    }
    return "<div>" + o.join('') + "</div>"
  end
  def cd *d
    self.dir.value = %[#{home}/#{d[0]}]
    if !Dir.exist? self.dir.value
      Dir.mkdir(self.dir.value)
    end
    if !File.exist?("#{self.dir.value}/index.json") && d.length > 0
      h = { goal: '', ga: '', fb: '', zone: U.new(@id).attr[:zone] }
      File.open("#{self.dir.value}/index.json", "w") { |f| f.write("#{JSON.generate(h)}"); }
      File.open("#{self.dir.value}/index.erb", "w") { |f| f.write("<h1>Hello, World!</h1>created: </h3><p><% Time.now.utc %></p>"); }
      File.open("#{self.dir.value}/index.markdown", "w") { |f| f.write("# Hello, World!\n\n## markdown is a simple way to organize text to be rendered as html.\n- it supports lists.\n- and tables,\n- etc.\n- google it."); }
    end
    return "#{self.dir.value.gsub(home, '')}"
  end
  def pwd
    if self.dir.value == nil
      self.dir.value = home
    end
    "#{self.dir.value}".gsub(home, '')
  end
  def home
    %[home/#{@id}]
  end
  def term
    ERB.new(TERM).result(binding)
  end
  def clear
    self.content.clear
    return nil
  end
  def peek
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true)
    o = []
    Dir["#{home}/*"].each {|f|
      if /.json/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + File.read(f) + "</fieldset>"
      elsif /.erb/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + ERB.new(File.read(f)).result(binding) + "</fieldset>"
      elsif /.markdown/.match(f)
        o << "<fieldset><legend>#{f.gsub(home, '')}</legend>" + markdown.render(File.read(f)) + "</fieldset>"
      end
    }
    return o.join('')
  end
  def id; @id; end
  
  def html
    o = []
    if self.attr[:file] == nil
      self.content.values.each {|e| o << e }
    else
      f = "#{self.dir.value}/#{self.attr[:file]}"
      if File.exist? f
        ff = File.read(f)
      else
        ff = ''
      end
      o << [%[<input type='hidden' name='editor[file]' value='#{f}'>],
            %[<textarea name='editor[content]' style='width: 100%; height: 80%;'>#{ff}</textarea>]].join('')
      
    end
    return o.join('')
  end
  def js
    self.scripts.values.join('; ')
  end
  def style a, h={}
    o = []; h.each_pair {|k,v| o << %[#{k}: #{v}] }
    self.styles << %[#{a} { #{o.join('; ')} }]
  end
  def css
    self.styles.values.join('')
  end
  def puts(e); return "#{e}"; end;
  def help; ERB.new(HELP).result(binding); end
  def edit(f);
    self.attr[:file] = f
  end
  def conf(*f)
    edit "#{f[0] || 'index'}.json"
  end
  def app(*f)
    edit "#{f[0] || 'index'}.erb"
  end
  def pin(*f)
    edit "#{f[0] || 'index'}.markdown"
  end
  
  
  def button(t, h={}); a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] };
    return %[<button #{a.join(' ')}>#{t}</button>]
  end
  def input(h={}); a = []; h.each_pair { |k,v| a << %[#{k}='#{v}'] }; return %[<input #{a.join(' ')}>]; end
  def sh c
    return `#{c}`.chomp!
  end
  def eval(e);
    begin;
      if e == ''; e = 'help'; end
      e.split(';').each { |ea| self.content << "#{self.instance_eval(ea)}".gsub("\n", '<br>') }
    rescue => e
      self.content << "<p>#{e.class} #{e.message}</p>"
    end
  end
end