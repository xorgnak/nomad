
require 'redis-objects'

class Net
  include Redis::Objects
  sorted_set :tracks
  def initialize i
    @id = i
  end
  def id; @id; end

  class Point
    include Redis::Objects
    sorted_set :tracks
    hash_key :attr
    sorted_set :stat
    def initialize i
      @id = i
    end
    def id; @id; end
    def map
      self.tracks.members(with_scores: true)
    end
  end
  def point p
    Point.new(p)
  end
  
  class Track
    include Redis::Objects
    sorted_set :points
    hash_key :attr
    sorted_set :stat
    def initialize i
      @id = i
    end
    def id; @id; end
    def map
      a = []
      self.points.members(with_scores: true).to_h.each_pair do |k,v|
        a << [ k, v, Point.new(k).map ]
      end
      return a
    end
  end
  def track i, *p
    self.tracks.incr(i)
    t = Track.new(i)
    [p].flatten.each { |e| t.points.incr(e); point(e).tracks.incr(i); }
    return t
  end

  def map
    a = []
    self.tracks.members(with_scores: true).to_h.each_pair do |k,v|
      a << [k, v, track(k).map ]
    end
    return a
  end
end



NET = Net.new 'localhost'
def test n
  n.times do
    t = [:adventure, :datenight, :girlsnight].sample
    p = [:club1, :club2, :club3, :bar1, :bar2, :bar3, :bar4, :bar5].sample
    NET.track t, p
  end
  return NET.map
end

def peep t
@t = NET.track(t)
end
