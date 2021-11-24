#
# do no edit.
#
# network wide configuration.
#
export DOMAIN_ROOT='localhost'; 
export PHONE_SID='dummy sid';
export PHONE_KEY='dummy key';
#
# end of network configuration.
#
#
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN_ROOT='';
export DOMAIN='';
export PORT='';
export PHONE='';
export ADMIN='';
export FREQUENCY='';
ruby nomad-coin.rb -p $PORT -d $DOMAIN -b $ADMIN -f $FREQUENCY -s $PHONE_SID -k $PHONE_KEY &
