#!/bin/bash

mkdir -p run
mkdir -p nginx
if [[ "$1" == "config" ]]; then
rm run.sh
cat <<EOF > run/$DOMAIN.sh;
#
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN_ROOT='$DOMAIN_ROOT';
export DOMAIN='$DOMAIN';
export PORT='$PORT';
export PHONE_SID='$PHONE_SID';
export PHONE_TOKEN='$PHONE_KEY';
export PHONE='$PHONE';
export ADMIN='$ADMIN';
export FREQUENCY='$FREQUENCY';
ruby nomad-coin.rb -p \$PORT -d \$DOMAIN -b \$ADMIN -f \$FREQUENCY &; 
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
    proxy_set_header Host $host;
    proxy_redirect http://localhost:$PORT https://$DOMAIN;
  }
  ssl_certificate /etc/letsencrypt/live/$DOMAIN_ROOT/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_ROOT/privkey.pem; # managed by Certbot 
}
EOF

elif [[ "$1" == "install" ]]; then
    sudo apt update && sudo apt upgrade && sudo apt install git screen ruby-full redis-server redis-tools build-essential certbot nginx emacs-nox;
    sudo gem install sinatra thin eventmachine slop redis-objects pry rufus-scheduler twilio-ruby;
elif [[ "$1" == "commit" ]]; then
    git add . && git commit && git push;
elif [[ "$1" == "quick" ]]; then
    ./nomad.sh install && ./nomad.sh config && ./nomad.sh $*
else
    for f in run/*.sh;
    do
	./run.sh
    done
    ruby nomad-coin.rb -i
fi
