class Tracks
  include Redis::Objects
  set :adventures
  set :waypoints
  hash_key :players
  def initialize i
    @id = i
  end
  def id; @id; end
  # an adventure track  
  def [] t
    if "#{t}".length > 0
    self.adventures << t
    z = Zone.new(t)
    z.adventures << adventure(t)
    Adventure.new(adventure(t))
    end
  end
  # user at waypoint
  def visit u, p
    if "#{u}".length > 0 && "#{p}".length > 0
      self.players[u] = p
      uu = U.new(u)
      uu.visited << p
      uu.attr[:waypoint] = p
      uu.attr.incr(:xp)
    end
  end

  #                  U   "say this" -> new track
  # zone, waypoint, password, for
  def mark z, w, p, f, a
    Redis.new.publish "WAYPOINT.mark", "#{z} #{w} #{p} #{f}"
    if "#{z}".length > 0 && "#{w}".length > 0 && "#{p}".length > 0 && "#{f}".length > 0
    @a = Adventure.new(adventure(z))
    @z = Zone.new(z)
    @z.adventures << adventure(z)
    @z.waypoints << @a[w].id
    @u = U.new(w)
    @u.waypoints << @a[w].id
    @a.contributors << @u.id
    @a[w].passwords[p] = { for: f }
    @a[w].attr[:goto] = a
    end
  end
  
  # collect aset of waypoints as a zone.
  def track zone, *waypoints
    if "#{zone}".length > 0
    self.adventures << zone
    a = Adventure.new(adventure(zone))
    z = Zone.new(zone)
    z.adventures << adventure(zone)
    [waypoints].flatten.each_with_index {|e, i|
      # adventure[waypoint].adventures << adventure(zone)
      if "#{e}".length > 0
      a[e].adventures << adventure(zone)
      z.waypoints << a[e].id
      end
    }
    return a
    end
  end
  
  def adventure p
    "#{@id}:#{p}"
  end
end


##
# TRACKS[request.host]track zone, *user
#
# TRACKS[request.host][zone].contributors << @user.id
# TRACKS[request.host][zone][waypoint].passwords[password] = { to: @user.id, for: desc }
#
# TRACKS[request.host][zone].visit(@user.id, waypoint)
#
# TRACKS[request.host][zone][waypoint].stat.incr(zone)
# TRACKS[request.host][zone].stat.incr(waypoint)


class Adventure
  include Redis::Objects
  set :waypoints
  hash_key :attr
  set :contributors
  sorted_set :stat
  hash_key :players
  def initialize i
    @id = i
  end
  def id
    @id
  end
  def [] p
    if "#{p}".length > 0
    self.waypoints << p
    Waypoint.new(p)
    end
  end
end

class Waypoint
  include Redis::Objects
  set :adventures
  hash_key :attr
  sorted_set :stat
  hash_key :passwords, marshal: true
  def initialize i
    @id = i
  end
  def id
    @id
  end
end