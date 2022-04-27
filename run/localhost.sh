#
# do no edit.
#
# network wide configuration.
#

# set to cluster root
# this is te server we connect to for telemetry and communications.
export CLUSTER='vango.me';
export NICK='nomad';

# set to the ssl certificate root for the system.
# this will be generated with letsencrypt.
export DOMAIN_ROOT=''; 

# comment this out for cloud (hub) usage.
# default: connect and announce to cluster.
export BOX='true';

# the twilio api sid and key used for sms authentication, etc.
export PHONE_SID='';
export PHONE_KEY='';



# uncomment to enable pi-bonnet interface.
#export BONNET='true';

# uncomment to enable duino-coin miner.
#export MINE='true';

# uncomment to enable mush.
#export MUSH='true';

# uncomment to auto proxy devices.
#export DEVS='true';
#
# end of network configuration.
#
#   
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN='localhost';
export PHONE='';
export ADMIN='';
export MUMBLE='';
export OWNERSHIP='sponsor';
export EXCHANGE='1';
export SHARES='100';
export XFER='true';
export PROCUREMENT='5';
export FULFILLMENT='30';
redis-cli hset PHONES localhost $PHONE > /dev/null; 
redis-cli hset MUMBLE localhost $MUMBLE > /dev/null;
redis-cli hset ADMINS localhost $ADMIN > /dev/null;
redis-cli hset OWNERSHIP localhost $OWNERSHIP > /dev/null;
redis-cli hset EXCHANGE localhost $EXCHANGE > /dev/null; 
redis-cli hset SHARES localhost $SHARES > /dev/null;
redis-cli hset XFER localhost $XFER > /dev/null;
redis-cli hset PROCUREMENT localhost $PROCUREMENT > /dev/null;
redis-cli hset FULFILLMENT localhost $FULFILLMENT > /dev/null;
ruby bin/mumble.rb localhost;
umurmurd -c mumble/$DOMAIN.conf
