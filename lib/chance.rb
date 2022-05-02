class Chance
  include Redis::Objects
  list :cards, marshal: true
  value :res, marshal: true
  value :try
  def initialize i
    @id = i
    @u = U.new(@id)
  end
  def id; @id; end
  def deal *n
    a, aa, t = [], [], 0
    [self.cards.shift(n[0].to_i || 1)].flatten.each {|e| t += e[:value]; a << e }
    a.each {|e| aa << %[#{e[:card]}#{e[:suit]}] }
    return { total: t, result: aa }                            
  end
  def try?
    if @u.attr.has_key?(:chance) && @u.attr[:chance] != 'none'
      return true
    else
      return false
    end
  end
  def try!
    @n = @u.attr[:rank].to_i + 1
    case @u.attr[:chance]
    when 'coin'
      t, a = 0, []; @n.times { c = coin; t += c[:total]; a << c[:result] }
      self.res.value = { total: t, result: a }
    when 'card'
      if self.cards.values.length - @n  >= 0
        deck
      end
      self.res.value = deal(@n)
    when 'dice'
      self.res.value = roll("#{@n}d#{@u.attr[:class].to_i + 1}") {|r| r }
    end
    self.try.value = success(result)
    return success?
  end
  def success i
    Redis.new.publish("CHANCE.success", "#{i} #{@u.attr.all}")
    if i[:total].to_i >= @u.attr[:rank].to_i
      return true
    else
      return false
    end
  end
  def success?
    self.try.value
  end
  def result
    self.res.value
  end
  def deck h={}
    de = []
    hh = {
      suits: ["&#9829;", "&#9830;", "&#9824;", "&#9827;"],
      numbers: (2..10).to_a,
      faces: [ :A, :K, :Q, :J ],
      special: [ :"&#x1F0CF;", :"&#x1F004;" ],
    }.merge(h)
    Redis.new.publish("CHANCE.deck", "#{hh}")
    self.cards.clear
      [hh[:suits]].flatten.each { |s|
        Redis.new.publish("CHANCE.deck.s", "#{s}")
        [:faces, :numbers].each { |k|
          Redis.new.publish("CHANCE.deck.k", "#{k}")
          if hh.has_key? k.to_sym
            [hh[k]].flatten.each {|e|
              if /\d+/.match("#{e}")
                v = e.to_i
              else
                v = 10
              end
              de << { suit: s, card: e, value: v }
              Redis.new.publish("CHANCE.deck.card", "s#{s} c#{e} v#{v}")
            }
          end
        }
      }
      [hh[:special]].flatten.each {|e| de << { suit: "#", card: e, value: 0 };
        Redis.new.publish("CHANCE.deck.special", "#{e}")
      }
    Redis.new.publish("CHANCE.deck.de", "#{de}")
    de.shuffle!
    de.each {|e| self.cards << e }
  end
  def coin
    c = rand(2)
    if c == 0
      t = "arrow_circle_up"
    else
      t = "arrow_circle_down"
    end
    Redis.new.publish("CHANCE.coin", "#{c} #{t}")
    { total: c, result: %[<span class='material-icons' style='vertical-align: middle;'>#{t}</span>] }
  end
  def roll i, &b
    b.call(die(i))
  end
  def die i
    r, tot = [], 0
    ii = i.split('d')
    ii[0].to_i.times { x = rand(ii[1].to_i) + 1; tot += x; r << x }
    Redis.new.publish("CHANCE.dice", "#{tot} #{r}")
    return { total: tot, result: r }
  end
  def zap u
    me = U.new(@id)
    a = "#{me.attr[:xp]}".length + 1
    you = U.new(u)
    me.zaps.increment
    you.spaz.increment
    d = "#{you.attr[:xp]}".length + 1
    z = die("#{d}d#{you.attr[:rank].to_i + you.attr[:class].to_i}")
    roll("#{a}d#{me.attr[:rank].to_i + me.attr[:class].to_i}") {|h|
      ic = %[<span class='material-icons'>crisis_alert</span>]
      icn_hit = %[<span class='material-icons' style='color: red;'>ads_click</span>]
      icn_miss = %[<span class='material-icons' style='color: green;'>adjust</span>]
      if h[:total] > z[:total]
        r = 1
        me.zapper.incr(you.id)
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        you.zapped.incr(me.id)
        me.attr.incr(:xp)
        icn = %[<span class='material-icons'>crisis_alert</span>]
        me.log << %[#{icn_hit} you zapped #{you.attr[:name] || 'another player'}.]
        you.log << %[#{icn_hit} you got zapped by #{me.attr[:name] || 'another player'}.]
      else
        r = 0
        me.zap.incr(you.id)
        you.zap.incr(me.id)
        icn = %[<span class='material-icons'>crisis_alert</span>]
        me.log << %[#{icn_miss} you missed #{you.attr[:name] || 'another player'}.]
        you.log << %[#{icn_miss} #{me.attr[:name] || 'another player'} missed you.]
      end
      me.attr.incr(:xp)
      you.attr.incr(:xp)
      u, t = 0, 0
      me.zapper.members(with_scores: true).to_h.each_pair {|k,v| u += 1; t += v }
      me.attr[:rank] = ( "#{me.zaps.value}".length + "#{me.spaz.value}".length ) - 1
      you.attr[:rank] = ( "#{you.zaps.value}".length + "#{you.spaz.value}".length ) - 1
      me.log << %[<span class='material-icons'>emoji_events</span>rank: #{me.attr[:rank]}]
      you.log << %[<span class='material-icons'>emoji_events</span>rank: #{you.attr[:rank]}]
      { me: h, you: z, total: r }
    }
  end
end