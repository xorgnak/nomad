#!/bin/bash


if [[ "$1" == "config" ]]; then
rm run.sh
cat <<EOF > run.sh;
#
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN='$DOMAIN';
export PORT='$PORT';
export GOOGLE='$GOOGLE';
export PHONE_SID='$PHONE_SID';
export PHONE_TOKEN='$PHONE_KEY';
export PHONE='$PHONE';
export ADMIN='$ADMIN';
export FREQUENCY='$FREQUENCY';
ruby nomad-coin.rb -p $PORT -d DOMAIN -b $ADMIN -f $FREQUENCY $*; 
EOF
emacs run.sh;
chmod +x run.sh;
cat <<EOF > /etc/nginx/sites-enabled/$DOMAIN
server {
  listen 443 ssl;
  listen [::]:443;
  server_name $DOMAIN;
  location / {
    proxy_pass http://localhost:$PORT;
    proxy_set_header Host $host;
    proxy_redirect http://localhost:$PORT https://$DOMAIN;
  }
  ssl_certificate /etc/letsencrypt/live/vango.me/fullchain.pem; # managed by Certbot                           
  ssl_certificate_key /etc/letsencrypt/live/vango.me/privkey.pem; # managed by Certbot 
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
  ./run.sh $*;
fi
