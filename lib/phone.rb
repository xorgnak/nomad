def phone_tree phone, h={}
  if h.keys.length > 0
    TREE[phone] = JSON.generate(h)
  end
end

class Phone
  def twilio
    if OPTS[:sid] != ''
      Twilio::REST::Client.new(ENV['PHONE_SID'], ENV['PHONE_KEY'])
    end
  end
  def send_sms h={}
    to = []
    [ h[:to] ].flatten.uniq.each do |t|
      if /^\+1#.+$/.match(t)
        if @cloud.zones.members.include? t.gsub(/\+1/, '')
          @cloud.zone(t.gsub(/\+1/, '')).admins.members.each { |e| to << e }
        else
          to << ENV['ADMIN']
        end
      elsif /^#.+/.match(t)
        if @cloud.zones.members.include? t
          @cloud.zone(t).admins.members.each {|e| to << e }
        else
          to << ENV['ADMIN']
        end
      else
        to << t
      end
    end
    to.each do |t|
      Redis.new.publish "DEBUG.send_sms", "#{t} #{h}"
      if OPTS[:sid] != ""
        if h[:body] != ''
          if h[:image]
            twilio.messages.create(
              to: t,
              from: ENV['PHONE'],
              body: h[:body],
              media_url: [ h[:image] ]
            )
          else
            twilio.messages.create(
              to: t,
              from: ENV['PHONE'],
              body: h[:body]
            )
          end
        end
      end
    end
  end
end
def phone
  Phone.new
end

class CallCenter
  def initialize phone
    tree = {
      message: "OK",
      file: nil,
      mode: 'callcenter',
      boss: ENV['ADMIN'],
      dispatcher: ENV['ADMIN'],
      pool: [],
      pagers: { '0' => '' }
    }
    @phone = phone
    if !TREE.has_key? @phone
      TREE[@phone] = JSON.generate(tree)
    end
    @tree = JSON.parse(TREE[phone])
  end
  def [] k
    @tree[k.to_s]
  end
  def []= k,v
    @tree[k.to_s] = v
  end
  def << u
    @tree['pool'] << u
    @tree['pool'].uniq!
  end
  def save!
    TREE[@phone] = JSON.generate(@tree)
  end
end