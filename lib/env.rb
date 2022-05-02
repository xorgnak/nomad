# encoding: utf-8

ID_SIZE = 16
VAULT_SIZE = 8

FEES = { xfer: 1 }

BDG = [
  :nomad,
  :pedicab,
  :food,
  :bike,
  :grill,
  :pathfinder,
  :kids,
  :meals,
  :pizza,
  :bar,
  :asian,
  :coffee,
  :influence,
  :referral,
  :directions,
  :adventure,
  :radio,
  :dispatch,
  :farmer,
  :cannabis,
  :medic,
  :guide,
  :fire,
  :calm,
  :developer,
  :party,
  :event,
  :nightlife,
  :hauling,
  :bus,
  :race,
  :building,
  :fixing,
  :emergency,
  :bug,
  :network,
  :comms
]


BADGES = {
  nomad: 'backpack',
  pedicab: 'bike_scooter',
  food: 'fastfood',
  bike: 'directions_bike',
  grill: 'outdoor_grill',
  pathfinder: 'highlight',
  kids: 'child_friendly',
  meals: 'restaurant',
  pizza: 'local_pizza',
  bar: 'local_bar',
  asian: 'set_meal',
  coffee: 'local_cafe',
  influence: 'campaign',
  referral: 'loyalty',
  directions: 'directions',
  adventure: 'explore',
  radio: 'radio',
  dispatch: 'support_agent',
  farmer: 'agriculture',
  cannabis: 'smoking_rooms',
  medic: 'medical_services',
  guide: 'tour',
  fire: 'local_fire_department',
  calm: 'self_improvement',
  developer: 'memory',
  party: 'celebration',
  event: 'festival',
  nightlife: 'nightlife',
  hauling: 'local_shipping',
  bus: 'airport_shuttle',
  race: 'sports_score',
  building: 'carpenter',
  fixing: 'construction',
  emergency: 'fire_extinguisher',
  bug: 'pest_control',
  network: 'router',
  comms: 'leak_add'
}

DEPS = {
  nomad: [ :bike, :dispatch, :pathfinder, :medic ],
  pedicab: [],
  food: [ :pizza, :grill, :asian, :meals, :coffee ],
  bike: [],
  grill: [],
  pathfinder: [ :directions ],
  kids: [],
  meals: [],
  pizza: [],
  bar: [],
  asian: [],
  coffee: [],
  influence: [ :fire ],
  referral: [],
  directions: [],
  adventure: [ :pedicab, :guide, :radio, :fire  ],
  radio: [],
  dispatch: [ :radio ],
  farmer: [],
  cannabis: [ :farmer ],
  medic: [],
  guide: [ :directions ],
  fire: [ :referral ],
  calm: [ :emergency ],
  developer: [ :comms ],
  party: [ :referral ],
  event: [ :party ],
  nightlife: [ :party ],
  hauling: [],
  bus: [ :hauling ],
  race: [ :pedicab ],
  building: [ :fixing ],
  fixing: [],
  emergency: [ :fixing, :medic ],
  bug: [],
  network: [ :bug ],
  comms: [ :radio, :network ]
}

DESCRIPTIONS = {
  nomad: 'able to operate autonomously.',
  pedicab: 'able to operate a pedicab.',
  food: 'knowledgable on the subject of food.',
  bike: 'able to operate a pedicab.',
  grill: 'knowlegable on the subject of grilled meat.',
  pathfinder: 'able to manage multiple transportation vectors.',
  kids: 'child friendly.',
  meals: 'knowlegable on the subject of sit down meals.',
  pizza: 'knowlegable on the subject of pizza.',
  bar: 'knowlegable on the subject of local bars.',
  asian: 'knowlegable on the subject of asian food.',
  coffee: 'knowlegable on the subject of local coffee.',
  influence: 'knowlegable on the subject of ultra-exclusive local events.',
  referral: 'knowlegable on the subject of local events.',
  directions: 'able to find things.',
  adventure: 'qualified to conduct adventures.',
  radio: 'qualified to use a radio.',
  dispatch: 'managing network radio operatons.',
  farmer: 'knowlegable on the subject of growing things.',
  cannabis: 'knowlegable on the subject of cannabis.',
  medic: 'able to help you.',
  guide: 'able to show you around.',
  fire: 'knowlegable on the subject of exclusive local events.',
  calm: 'a field network operator.',
  developer: 'helping keep the network working.',
  party: 'special event coordination.',
  event: 'large scale event coordination.',
  nightlife: 'nightlife specialist.',
  hauling: 'is experienced in shipping.',
  bus: 'long distance transportation.',
  race: 'a pedicab racer.',
  building: 'good at building things.',
  fixing: 'good at fixing things.',
  emergency: 'coordinating disasters.',
  bug: 'finding software problems.',
  network: 'fixing network problems',
    comms: 'developing network solutions.'
}

ICONS = {
  call: 'call',
  sms: 'message',
  tip: 'cash',
  venmo: 'venmo',
  facebook: 'facebook',
  instagram: 'instagram',
  snapchat: 'snapchat'
}

CRON = Rufus::Scheduler.new
DOMAINS = Redis::Set.new("DOMAINS")
VOTES = Redis::Set.new("VOTES")
ZONES = Redis::Set.new("ZONES")
TITLES = Redis::Set.new("TITLES")
CHA = Redis::HashKey.new('CHA')
IDS = Redis::HashKey.new('IDS')
DEVS = Redis::HashKey.new('DEVS')
DB = Redis::HashKey.new('DB')
BOOK = Redis::HashKey.new('BOOK')
PAGERS = Redis::HashKey.new('PAGERS')
LOOK = Redis::HashKey.new('LOOK')
HEAD = Redis::HashKey.new('HEAD')
LANDING = Redis::HashKey.new('LANDING')
FOOT = Redis::HashKey.new('FOOT')
LOCKED = Redis::HashKey.new('LOCKED')
CODE = Redis::HashKey.new('CODE')
TREE = Redis::HashKey.new('TREE')
LOCS = Redis::Set.new("LOCS")
ADVENTURES = Redis::Set.new("ADVENTURES")
CAMS = Redis::HashKey.new("CAMS")
QRI = Redis::HashKey.new("QRI")
QRO = Redis::HashKey.new("QRO")
LOGINS = Redis::HashKey.new("LOGINS")
QUICK = Redis::HashKey.new("QUICK")
MUMBLE = Redis::HashKey.new('MUMBLE')
PHONES = Redis::HashKey.new("PHONES")
ADMINS = Redis::HashKey.new("ADMINS")
OWNERSHIP = Redis::HashKey.new("OWNERSHIP")
EXCHANGE = Redis::HashKey.new("EXCHANGE")
SHARES = Redis::HashKey.new("SHARES")
TOS = Redis::HashKey.new('TOS')
FRANCHISE = Redis::HashKey.new("FRANCHISE")
PROCUREMENT = Redis::HashKey.new('PROCUREMENT')
FULFILLMENT = Redis::HashKey.new('FULFILLMENT')
XFER = Redis::HashKey.new("XFER")
OTP = Redis::HashKey.new('OTP')
OTK = Redis::HashKey.new('OTK')
LVLS = Redis::HashKey.new("LVLS")
SASH = Redis::HashKey.new("SASH")
LOAD = Redis::HashKey.new("LOAD")
INIT = Redis::HashKey.new("INIT")
CSS = Redis::HashKey.new("CSS")

PINS = ['trip_origin', 'circle', 'adjust', 'stop', 'check_box_outline_blank', 'star', 'star_border', 'stars', 'spa'];

JOBS = Redis::HashKey.new('JOBS')

STATE = Redis::HashKey.new('STATE')
