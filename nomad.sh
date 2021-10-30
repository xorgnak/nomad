#!/bin/bash

DEBS='git screen ruby-full redis-server redis-tools build-essential certbot nginx emacs-nox mosquitto';
GEMS='sinatra thin eventmachine slop redis-objects pry rufus-scheduler twilio-ruby redcarpet paho-mqtt';


mkdir -p run
mkdir -p nginx
mkdir -p home

if [[ "$1" == "config" ]]; then
    rm run.sh
    mkdir -p public/$DOMAIN
    cat ~/nomad.conf > run/$DOMAIN.sh
cat <<EOF >> run/$DOMAIN.sh;
#
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN_ROOT='$DOMAIN_ROOT';
export DOMAIN='$DOMAIN';
export PORT='$PORT';
export PHONE='$PHONE';
export ADMIN='$ADMIN';
export FREQUENCY='$FREQUENCY';
ruby nomad-coin.rb -p \$PORT -d \$DOMAIN -b \$ADMIN -f \$FREQUENCY -s \$PHONE_SID -k \$PHONE_KEY &
EOF
emacs run/$DOMAIN.sh;
chmod +x run/$DOMAIN.sh;
sudo cat <<EOF > nginx/$DOMAIN.conf
server {
  listen 443 ssl;
  listen [::]:443;
  server_name $DOMAIN;
  location / {
    proxy_pass http://localhost:$PORT;
    proxy_set_header Host \$host;
    proxy_redirect http://localhost:$PORT https://$DOMAIN;
  }
  ssl_certificate /etc/letsencrypt/live/$DOMAIN_ROOT/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_ROOT/privkey.pem; # managed by Certbot 
}
EOF

sudo cp nginx/* /etc/nginx/sites-enabled/
sudo service nginx restart

elif [[ "$1" == "install" ]]; then
    if [[ ! -f ~/nomad.conf ]]; then
    cat <<EOF > ~/nomad.conf
#
# do no edit.
#
# network wide configuration.
#
export DOMAIN_ROOT='$DOMAIN_ROOT'; 
export PHONE_SID='$PHONE_SID';
export PHONE_KEY='$PHONE_KEY';
#
# end of network configuration.
#
EOF
    nano ~/nomad.conf
    fi
    sudo apt update && sudo apt upgrade && sudo apt install $DEBS;
    sudo gem install $GEMS;
    sudo cp nginx.conf /etc/nginx/
    sudo service nginx restart
elif [[ "$1" == "commit" ]]; then
    git add . && git commit && git push;
elif [[ "$1" == "quick" ]]; then
    ./nomad.sh install && ./nomad.sh config && ./nomad.sh $*
else
    if [[ "$1" != "dev" ]]; then
	git pull;
    fi
    for f in run/*.sh;
    do
	./$f
    done
    if [[ "$1" == 'pi' ]]; then
	sudo ruby bonnet.rb &
    fi
    ruby nomad-coin.rb -i
fi
