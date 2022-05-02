class U
  include Redis::Objects
  set :waypoints
  set :visited
  set :jobs
  set :items
  set :reps
  sorted_set :wallet
  sorted_set :awards
  sorted_set :stripes
  sorted_set :badges
  sorted_set :stat
  sorted_set :boss
  sorted_set :zap
  sorted_set :zapper
  sorted_set :zapped
  set :votes
  set :zones
  set :jobs
  set :titles
  hash_key :attr
  counter :coins
  counter :zaps
  counter :spaz
  list :log
  value :pin, expireat: 180
  value :password
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def sash
    Sash.new(@id)
  end
end

class Sash
  def initialize u, *b
    @u = U.new(u)
  end
  def [] b
    {
      name: b,
      dependancies: DEPS[b],
      for: DESCRIPTIONS[b],
      badges: @u.badges[b],
      awards: @u.awards[b],
      stripes: @u.stripes[b],
      boss: @u.boss[b]
    }
  end
  def << b
    if [DEPS[b.to_sym]].flatten.length > 0
      d = false
      DEPS[b.to_sym].each { |e| if @u.boss[e].to_i > 1 || @u.attr[:boss].to_i > 0; d = true; end  }
    else
      d = true
    end
    if d == true;
      @u.badges.incr(b);
      @u.boss[b] = "#{@u.badges[b].to_i}".length
      @u.stripes[b] = "#{@u.boss[b].to_i}".length
      @u.log << %[<span class='material-icons'>military_awards</span> you earned a #{b} badge.]
    end
  end

  def colors b,f,d
    bg = { 0 => 'darkgrey', 1 => 'white', 2 => 'lightblue', 3 => 'lightgreen', 4 => 'red' }
    fg = { 0 => 'lightgrey', 1 => 'purple', 2 => 'orange', 3 => 'green', 4 => 'blue', 5 => 'red', 6 => 'brown', 7 => 'yellow', 8 => 'magenta' }
    bd = { 0 => 'darkgrey', 1 => 'purple', 2 => 'orange', 3 => 'green', 4 => 'blue', 5=> 'red', 6 => 'brown', 7 => 'yellow', 8 => 'magenta' }
    h =  { fg: fg[f.to_i] || 'gold', bg: bg[b.to_i] || 'black', bd: bd[d.to_i] || 'gold' }
  end
  
  def style b,f,d,p,r
    cl = colors(b,f,d)
    bd = ['none', 'solid', 'dotted']
    s = [%[background-color: #{cl[:bg]};]];
    s << %[color: #{cl[:fg]};]
    s << %[border: thick #{bd[p.to_i] || 'dashed'} #{cl[:bd]};]
    s << %[border-radius: #{r}px;]
    return { style: s.join(' '), colors: cl, }
  end

  def lvl
    r, ps = [], []
    if @u.attr[:boss].to_i > 0
      "#{@u.attr[:boss]}".length.times {
        ps << %[<span class='material-icons pin'>#{PINS[@u.attr[:class].to_i + 1]}</span>]
      }
    end
    @u.attr[:rank].to_i.times { r << %[<span class='material-icons pin'>#{PINS[0]}</span>] }    
    p = style("#{@u.attr[:boss].to_i}".length - 1, "#{@u.attr[:xp].to_i}".length - 1, @u.attr[:class], @u.attr[:class], 0)
    return %[<div id='lvl' style='#{p[:style]};'><div>#{ps.join('')}</div><div>#{r.join('')}</div></div>]
  end
  
  def badges
    r, t = [], Hash.new { |h,k| h[k] = 0 }
    @bgs = @u.badges.members(with_scores: true).to_h
    @bss = @u.boss.members(with_scores: true).to_h
    @awd = @u.awards.members(with_scores: true).to_h
    @stp = @u.stripes.members(with_scores: true).to_h
    BADGES.each_pair do |k,v|
      @u.boss[k.to_s] = "#{@bgs[k.to_s].to_i}".length - 1
      @u.stripes[k.to_s] = "#{@awd[k.to_s].to_i}".length
      t[:badges] += @bgs[k.to_s] || 0
      t[:boss] += @bss[k.to_s] || 0
      t[:awards] += @awd[k.to_s] || 0
      t[:stripes] += @stp[k.to_s] || 0
      if @bgs[k.to_s].to_i > 9
        g = "#{@bgs[k.to_s].to_i}"[-1]
      else
        g = @bgs[k.to_s]
      end
      if @awd[k.to_s].to_i > 9
        w = "#{@awd[k.to_s].to_i}"[0]
      else
        w = @awd[k.to_s]
      end
      p = style(@bss[k.to_s], g, w, @stp[k.to_s], 1000);
      r << %[<button class='material-icons badge' name='give[type]' value='#{k}' style='#{p[:style]}'>#{v}</button>]
    end
    @u.stat[:badges] = t[:badges]
    @u.stat[:boss] = t[:boss]
    @u.stat[:awards] = t[:awards]
    @u.stat[:stripes] = t[:stripes]
    return %[<div id='badges'>#{r.join('')}</div>]
  end
end

def user u
  U.new(u)
end