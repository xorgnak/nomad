#!/bin/bash

DEBS='git screen ruby-full redis-server redis-tools build-essential certbot nginx ngircd tor emacs-nox mosquitto python3 python3-pip git python3-pil python3-pil.imagetk mednafen';
GEMS='sinatra thin eventmachine slop redis-objects pry rufus-scheduler twilio-ruby redcarpet paho-mqtt cerebrum cryptology ruby-mud faker sinatra-websocket browser securerandom sentimental mqtt';

if [[ "$1" == 'boot' ]]; then
    rm -f nomad.lock
fi

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

#sudo cp nginx/* /etc/nginx/sites-enabled/
#sudo service nginx restart

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
export BONNET='false';
export MINE='false';
export MUSH='false'
#
# end of network configuration.
#
EOF
    
    nano ~/nomad.conf
    fi
    sudo ./nomadic/exe/nomad.sh
    sudo chown $USERNAME:$USERNAME ~/*
    sudo chown $USERNAME:$USERNAME ~/.*

    MICRO_VERSION=$(curl -s "https://api.github.com/repos/zyedidia/micro/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    cd ~
    curl -Lo micro.tar.gz "https://github.com/zyedidia/micro/releases/latest/download/micro-${MICRO_VERSION}-linux-arm.tar.gz"
    tar xf micro.tar.gz
    sudo mv "micro-${MICRO_VERSION}/micro" /usr/local/bin
    rm -rf micro.tar.gz
    rm -rf "micro-${MICRO_VERSION}"
    sudo nano /etc/hostname

    cd ~
    git clone https://github.com/revoxhere/duino-coin
    cd duino-coin
    python3 -m pip install -r requirements.txt
    python3 PC_Miner.py
    
    (sudo crontab -l 2>/dev/null; echo "@reboot cd /home/pi/nomad && ./nomad.sh boot")| sudo crontab -
    echo "##### REBOOT!!! #####"
elif [[ "$1" == "update" ]]; then
    sudo ./nomadic/exe/nomad.sh
elif [[ "$1" == "init" ]]; then
    sudo apt update && sudo apt upgrade -y && sudo apt install -y $DEBS;
    sudo gem install $GEMS;
elif [[ "$1" == "commit" ]]; then
    git add . && git commit && git push;
elif [[ "$1" == "arduino" ]]; then
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
    sudo cp bin/arduino-cli /usr/local/bin/arduino-cli
    rm -fR bin
    arduino-cli config init
    cat <<EOF > ~/.arduino15/arduino-cli.yaml
board_manager:
  additional_urls: ["https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json", "https://github.com/Heltec-Aaron-Lee/WiFi_Kit_series/releases/download/0.0.5/package_heltec_esp32_index.json", "https://arduino.esp8266.com/stable/package_esp8266com_index.json"]
daemon:
  port: "50051"
directories:
  data: /home/pi/.arduino15
  downloads: /home/pi/.arduino15/staging
  user: /home/pi/Arduino
library:
  enable_unsafe_install: true
logging:
  file: ""
  format: text
  level: info
metrics:
  addr: :9090
  enabled: true
output:
  no_color: false
sketch:
  always_export_binaries: false
updater:
  enable_notification: true
EOF
    arduino-cli core update-index
    arduino-cli core install esp32:esp32
    arduino-cli core install esp8266:esp8266
    
    echo "### NOMAD arduino-cli begin ###" >> ~/.bashrc
    echo "function upload() { source config.sh; echo \"\$FQBN\"; arduino-cli compile --fqbn \$FQBN \`pwd\` && arduino-cli upload --port /dev/ttyUSB0 --fqbn \$FQBN \`pwd\`; }" >> ~/.bashrc
    echo 'echo "upload -> upload sketch to device"' >> ~/.bashrc
    echo "alias monitor='cat /dev/ttyUSB0'" >> ~/.bashrc
    echo 'echo "monitor -> monitor serial traffic from device"' >> ~/.bashrc
    echo "function arduino() { arduino-cli lib install \"$1\"; }" >> ~/.bashrc
    echo 'echo "arduino <library> -> install arduino library"' >> ~/.bashrc
    echo "function sketch() { arduino-cli sketch new \"\$1\" && echo 'export FQBN=\"\"' > \$1/config.sh && micro \$1/config.sh && micro \$1/\$1.ino; }" >> ~/.bashrc
    echo 'echo "sketch <name> -> create new arduino sketch."' >> ~/.bashrc
    echo "### NOMAD arduino-cli end ###" >> ~/.bashrc
else
    source /home/pi/nomad.conf
    if [[ -f nomad.lock ]]; then
	ruby nomad-coin.rb -I
    else
	if [[ "$BONNET" == 'true' ]]; then
	    sudo ruby bonnet.rb &
	fi
	if [[ "$MINE" == 'true' ]]; then
	    (cd /home/pi/duino-coin && python3 PC_Miner.py &)
	fi
	if [[ "$MUSH" == 'true' ]]; then
	    ruby mud.rb &
	fi
	if [[ "$DEVS" == 'true' ]]; then
	    ruby proxy_sub.rb &
	fi
	for f in run/*.sh;
	do
	    ./$f
	done
	touch nomad.lock
	ruby nomad-coin.rb -i
    fi
    cleanup() {
	rm nomad.lock
        echo "EXIT"
        exit 0
    }
    trap cleanup INT TERM

fi
