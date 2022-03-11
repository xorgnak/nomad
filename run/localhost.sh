# network wide configuration.
# this is te server we connect to for telemetry and communications.
export CLUSTER='vango.me';
export NICK='nomad';
# certbot registration email.
export EMAIL='xorgnak@gmail.com';
# the first domain in DOMAINS or the renewed certificate generated by certbot.
export DOMAIN_ROOT='';
# set to false for cloud (hub) usage; true for local (node) usage.
export BOX='true';
# pre-configure domains for hub
export DOMAINS='';
# the twilio api sid and key used for sms authentication, etc.
export PHONE_SID='';
export PHONE_KEY='';
#export IOT='true';
#export GUI="true";
#export BONNET='true';
#export MINE='true';
#export MUSH='true';
#export DEVS='true';
export COMMS='true';
export MUMBLE=64738;
export OWNERSHIP='sponsor';
export EXCHANGE='1';                                                           
# end of network configuration.
#   
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN='localhost';
export PHONE='';
export ADMIN='';
export MUMBLE='64738';
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
