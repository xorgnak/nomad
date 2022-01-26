#!/bin/bash

DEBS='git screen ruby-full redis-server redis-tools build-essential certbot nginx ngircd tor emacs-nox mosquitto python3 python3-pip git python3-pil python3-pil.imagetk mumble-server golang alsa-base alsa-tools alsa-utils';
DEBS_HAM='soundmodem multimon-ng ax25-apps ax25-tools golang libopus0 libopus-dev libopenal-dev';
DEBS_FUN='games-console tintin++ slashem';
DEBS_GUI='xinit xwayland terminator chromium dwm mumble vlc mednafen mednaffe';
DEBS_SHELL='shellinabox openssl'
GEMS='sinatra thin eventmachine slop redis-objects pry rufus-scheduler twilio-ruby redcarpet paho-mqtt cerebrum cryptology ruby-mud faker sinatra-websocket browser securerandom sentimental mqtt bundler cinch';

if [[ ! -f ~/nomad.conf ]]; then
        cat << EOF > ~/nomad.conf                                                                                                                        
# do no edit.                                                                                                                                            
# network wide configuration.                                                                                                                            
# this is te server we connect to for telemetry and communications.                                                                                      
export CLUSTER='localhost';                                                                                                                              
export NICK='nomad';                                                                                                                                     
# set to the ssl certificate root for the system.                                                                                                        
export DOMAIN_ROOT='$DOMAIN_ROOT';                                                                                                                       
# comment this out for cloud (hub) usage.                                                                                                                
export BOX='true';                                                                                                                                       
# the twilio api sid and key used for sms authentication, etc.                                                                                           
export PHONE_SID='$PHONE_SID';                                                                                                                           
export PHONE_KEY='$PHONE_KEY';
#export GUI="true";
#export BONNET='true';                                                                                                                                   
#export MINE='true';                                                                                                                                     
#export MUSH='true';                                                                                                                                     
#export DEVS='true';                                                                                                                                     
# end of network configuration.                                                                                                                          
EOF
	editor ~/nomad.conf
fi
source ~/nomad.conf

if [[ "$1" == 'boot' ]]; then
    rm -f nomad.lock
fi

mkdir -p run
mkdir -p nginx
mkdir -p home

if [[ "$1" == "-h" || "$1" == "-u" || "$1" == "--help" || "$1" == "help" ]]; then
    echo "usage: $0 [install [gui]|config|update|iot|sd|op]"
    echo "install: normalize system, install packages, and install gems."
    echo "install gui: install system with graphical tools."
    echo "config: add a domain configuration to the nomad instance."
    echo "update: update the nomad instace."
    echo "iot: install hardware device platform."
    echo "sd: pre-configure raspberry pi os for network."
    echo "op: begin operator mode."
elif [[ "$1" == "config" ]]; then
    mkdir -p public/$DOMAIN
    cat ~/nomad.conf > run/$DOMAIN.sh
cat <<EOF >> run/$DOMAIN.sh;
#
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN='$DOMAIN';
export PORT='$PORT';
export PHONE='$PHONE';
export ADMIN='$ADMIN';
ruby nomad-coin.rb -p \$PORT -d \$DOMAIN -b \$ADMIN -s \$PHONE_SID -k \$PHONE_KEY
EOF
editor run/$DOMAIN.sh;
chmod +x run/$DOMAIN.sh;
cat <<EOF > nginx/$DOMAIN.conf
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
elif [[ "$1" == "update" ]]; then
    sudo ./nomadic/exe/nomad.sh
    sudo cp -f nginx/* /etc/nginx/sites-enabled/
    sudo chown $USERNAME:$USERNAME ~/*
    sudo chown $USERNAME:$USERNAME ~/.*
    echo "##### REBOOT TO RUN #####"
elif [[ "$1" == 'sd' ]]; then
    sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /media/pi/boot/
    sudo touch /media/pi/boot/ssh
    sudo cp -fR ~/nomad /media/pi/rootfs/home/pi/
elif [[ "$1" == 'operator' ]]; then
    source ~/nomad.conf
    $(go env GOPATH)/bin/barnard -insecure -server $CLUSTER:64738 -username `hostname`-$NICK;
elif [[ "$1" == "install" ]]; then
    echo "##### normalizing..."
#    su -c "editor /etc/apt/sources.list && /sbin/usermod -aG sudo $USER && apt update && apt upgrade && apt install sudo git"
    echo "##### normal."
    debs="$DEBS $DEBS_HAM $DEBS_FUN ";
    if [[ "$GUI" == "true" ]]; then
	debs="$debs $DEBS_GUI";
    fi
    if [[ "$BOX" == 'true' ]]; then
	debs="$debs $DEBS_SHELL";
    fi
    echo "##### installing debs..."
    sudo apt update && sudo apt upgrade -y && sudo apt install -y $debs;
    #echo $debs
    echo "##### post-install..."
    sudo mv /etc/shellinabox/options-enabled/00\+Black\ on\ White.css /etc/shellinabox/options-enabled/00_Black\ on\ White.css
    sudo mv /etc/shellinabox/options-enabled/00_White\ On\ Black.css /etc/shellinabox/options-enabled/00+White\ On\ Black.css
    echo "##### installing gems..."
    sudo gem install $GEMS;
    echo "##### installing comms";
    go get -u layeh.com/barnard
    sudo cp -f alsa.conf /usr/share/alsa/alsa.conf
    sudo cat << EOF > /etc/asound.conf
pcm.!default {
 type hw
 card 1
}
ctl.!default {
 type hw
 card 1
}
EOF
    if [[ "$MINE" == 'true' ]]; then
	cd ~
	git clone https://github.com/revoxhere/duino-coin
	cd duino-coin
	python3 -m pip install -r requirements.txt
	python3 PC_Miner.py
    fi
    (sudo crontab -l 2>/dev/null; echo "@reboot cd /home/pi/nomad && ./nomad.sh boot") | sudo crontab -
    sudo raspi-config
    echo "##### DONE! #####"
elif [[ "$1" == "iot" ]]; then
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
    sudo cp bin/arduino-cli /usr/local/bin/arduino-cli
    rm -fR bin
    /usr/local/bin/arduino-cli config init
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
	if [[ "$BOT" == 'true' ]]; then
	    ruby cluster.rb &
	fi
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
	    ./$f &
	    PIDS="$PIDS $!";
	done
	touch nomad.lock
	if [[ "BOX" != 'false' ]]; then
	    redis-cli set ONION `cat /var/lib/tor/nomad/hostname`
	    ruby nomad-coin.rb -i
	    PIDS="$PIDS $!";
	else
	    redis-cli del ONION
	fi
    fi
    cleanup() {
	rm nomad.lock
        exit 0
    }
    trap cleanup INT TERM 
fi
