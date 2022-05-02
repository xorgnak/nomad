@man = Slop::Options.new
@man.symbol '-s', '--sid', "the twilio sid", default: ''
@man.symbol '-k', '--key', "the twilio key", default: ''
@man.bool '-i', '--interactive', 'run interactively', default: false
@man.bool '-I', '--indirect', 'run indirectly', default: false
['-h', '-u', '--help', '--usage', 'help', 'usage'].each { |e| @man.on(e) { puts @man; exit; }}

OPTS = Slop::Parser.new(@man).parse(ARGF.argv)
