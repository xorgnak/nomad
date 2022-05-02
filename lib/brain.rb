class Me
  def initialize u
    @user = U.new(u)
    @brain = Cerebrum.new
    @mood = Sentimental.new
    @mood.load_defaults
    @mood.threshold = 0.1
  end
  def mood
    @mood
  end
  def feel f
    @mood.sentiment f
    @mood.score f
  end
  
  def brain
    @brain
  end
  def learn loc
    da = {}
    @user.badges.members(with_scores: true).to_h.each_pair do |b, s|
      da[b] = (s / 1000000).to_f
    end
    dat = { input: da, output: { "#{loc}" => 1 }}
    @brain.train([dat])
  end
  def predict
    u = @user.badges.members(with_scores: true).to_h
    @brain.run(u)
  end
end

def learn d, u, l
  da = {}
  U.new(u).badges.members(with_scores: true).to_h.each_pair do |b, s|
    da[b] = (s / 1000000).to_f
  end
  dat = { input: da, output: { "#{l}" => 1 }}
  { me: ME[d][u].learn(l), we: WE[d].train([dat]) }
end

def predict d, u
  uu = U.new(u).badges.members(with_scores: true).to_h
  { me: ME[d][u].predict, we: WE[d].run(uu) }
end