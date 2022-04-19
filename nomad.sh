#!/bin/bash

DEBS='git screen ruby-full redis-server redis-tools build-essential nginx ngircd tor emacs-nox mosquitto python3 python3-pip git python3-pil python3-pil.imagetk golang pulseaudio pulseaudio-module-bluetooth alsa-base alsa-tools alsa-utils imagemagick';
DEBS_HAM='soundmodem multimon-ng ax25-apps ax25-tools golang libopus0 libopus-dev libopenal-dev libconfig-dev libprotobuf-c-dev libssl-dev cmake autotools-dev autoconf libtool openssl';
DEBS_FUN='games-console tintin++ slashem';
DEBS_GUI='xinit xwayland terminator chromium dwm mumble vlc mednafen mednaffe';
DEBS_SSL='python-nginx-certbot certbot';
DEBS_SHELL=''
GEMS='sinatra thin eventmachine slop redis-objects pry rufus-scheduler redcarpet paho-mqtt cerebrum cryptology ruby-mud faker sinatra-websocket browser securerandom sentimental mqtt bundler cinch rqrcode webpush twilio-ruby rmagick binance';

mkdir -p mumble run home public
function debug() {
    echo "[$1] $2";
    redis-cli publish "DEBUG.nomad.sh.$1" "$2" > /dev/null;
}
function domain() {
    debug "domain" $1
    mkdir -p public/$1
    cat ~/nomad.conf > run/$1.sh
    cat << EOF >> run/$1.sh
#   
# EDIT TO SUIT YOUR NEEDS.
#
export DOMAIN='$1';
export PHONE='`redis-cli hget PHONES $1 || $PHONE`';
export ADMIN='`redis-cli hget ADMINS $1 || $ADMIN`';
export MUMBLE='$MUMBLE';
export OWNERSHIP='`redis-cli hget OWNERSHIP $1 || "franchise"`';
export EXCHANGE='`redis-cli hget EXCHANGE $1 || "1"`';
export SHARES='`redis-cli hget SHARES $1 || 100`';
export XFER='`redis-cli hget XFER $1 || "true"`';
export PROCUREMENT='`redis-cli hget PROCUREMENT $1 || "5"`';
export FULFILLMENT='`redis-cli hget FULFILLMENT $1 || "60"`';
redis-cli hset PHONES $1 \$PHONE > /dev/null; 
redis-cli hset MUMBLE $1 \$MUMBLE > /dev/null;
redis-cli hset ADMINS $1 \$ADMIN > /dev/null;
redis-cli hset OWNERSHIP $1 \$OWNERSHIP > /dev/null;
redis-cli hset EXCHANGE $1 \$EXCHANGE > /dev/null; 
redis-cli hset SHARES $1 \$SHARES > /dev/null;
redis-cli hset XFER $1 \$XFER > /dev/null;
redis-cli hset PROCUREMENT $1 \$PROCUREMENT > /dev/null;
redis-cli hset FULFILLMENT $1 \$FULFILLMENT > /dev/null;
ruby bin/mumble.rb $1;
umurmurd -c mumble/\$DOMAIN.conf
EOF
    chmod +x run/$1.sh;
}

if [[ ! -f ~/nomad.conf ]]; then
    if [[ "$DOMAINS" == "" ]]; then
	export BOX='true';
    else
	export BOX='false';
    fi
    debug box $BOX
    cat << EOF > ~/nomad.conf
# network wide configuration.
# this is te server we connect to for telemetry and communications.
export CLUSTER='localhost';
export NICK='nomad';
# certbot registration email.
export EMAIL='$EMAIL';
# the first domain in DOMAINS or the renewed certificate generated by certbot.
export DOMAIN_ROOT='$DOMAIN_ROOT';
# set to false for cloud (hub) usage; true for local network usage.
export BOX='$BOX';
# pre-configure domains for hub
export DOMAINS='$DOMAINS';
# the twilio api sid and key used for sms authentication, etc.
export PHONE_SID='$PHONE_SID';
export PHONE_KEY='$PHONE_KEY';
#export IOT='true';
#export GUI="true";
#export BONNET='true';
#export MINE='true';
#export MUSH='true';
#export DEVS='true';
#export COMMS='true';
export MUMBLE=64738;
export OWNERSHIP='sponsor';
export EXCHANGE='1';                                                           
# end of network configuration.
EOF
    editor ~/nomad.conf
    source ~/nomad.conf
    if [[ "$DOMAINS" != "" ]]; then
	sudo apt update && sudo apt upgrade && sudo apt install -y $DEBS_SSL && ruby bin/certbot.rb $DOMAINS;
	d=($DOMAINS);
	for ((i = 0; i < ${#d[@]}; ++i)); do
	    export MUMBLE=$(( $i + $MUMBLE + 1 ));
	    domain ${d[$i]};
	done
    fi
    domain 'localhost'
fi



source ~/nomad.conf

domain 'localhost'

debug 'init' "0"

if [[ "$1" == 'boot' ]]; then
    sudo pkill ruby
    sudo pkill umurmurd
    rm -f nomad.lock
fi

debug 'init' "1"

if [[ "$1" == "-h" || "$1" == "-u" || "$1" == "--help" || "$1" == "help" ]]; then
    echo "usage: ./nomad.sh [install|update|iot|sd|op]"
    echo "install: normalize system, install packages, and install gems."
    echo "install gui: install system with graphical tools."
    echo "install bare: run installer without package installation."
    echo "update: update the nomad instace."
    echo "iot: install hardware device platform."
    echo "sd: pre-configure raspberry pi os for network."
    echo "op: begin operator mode."
elif [[ "$1" == "update" ]]; then
    echo "##### UPDATE INIT #####"
    source ~/nomad.conf
    sudo ./scripts/nomad.sh
    if [[ "$DOMAINS" != "" ]]; then
	d=($DOMAINS);
	for ((i = 0; i < ${#d[@]}; ++i)); do
	    export MUMBLE=$(( $i + $MUMBLE + 1 ));
	    domain ${d[$i]};
	done
    fi
    domain 'localhost'
    sudo chown $USERNAME:$USERNAME ~/*
    sudo chown $USERNAME:$USERNAME ~/.*
    echo "##### UPDATE DONE #####"
elif [[ "$1" == 'sd' ]]; then
    echo "##### SD INIT #####"
    sudo cp -fvv /etc/wpa_supplicant/wpa_supplicant.conf /media/pi/boot/
    sudo touch /media/pi/boot/ssh
#    sudo cp -fRv ~/nomad /media/pi/rootfs/home/pi/
    echo "##### SD DONE #####"
elif [[ "$1" == 'operator' ]]; then
    echo "##### OP INIT #####"
    source ~/nomad.conf
    srv='';
    nck='';
    if [[ "$2" != "" ]]; then
	srv+=$2;
	nck=$NICK;
    else
	srv=$CLUSTER:$MUMBLE;
	nck=`hostname`-$NICK;
    fi
     "connecting to $srv as $nck";
    $(go env GOPATH)/bin/barnard -insecure -server $srv -username $nck;
    echo "##### OP DONE #####"
elif [[ "$1" == "install" ]]; then
    echo "##### INSTALL INIT #####"
    here=`pwd`
    if [[ `cat /proc/cpuinfo | grep Model` != *"Raspberry"* ]]; then
    echo "##### normalizing..."
    su -c "editor /etc/apt/sources.list && /sbin/usermod -aG sudo $USER && apt update && apt upgrade && apt install sudo git"
    echo "##### normal."
    fi
    sudo ./scripts/nomad.sh;
    
    debs="$DEBS $DEBS_HAM $DEBS_FUN ";

    if [[ "$GUI" == "true" ]]; then
	debs="$debs $DEBS_GUI";
    fi

    if [[ "$BOX" == 'true' ]]; then
	debs="$debs $DEBS_SHELL";
    fi

    if [[ "$1" == "install" && "$2" != 'bare' ]]; then
    echo "##### installing debs..."
    sudo apt update && sudo apt upgrade -y && sudo apt install -y $debs;
    sudo gem install $GEMS;
    fi
    
    if [[ "$COMMS" == 'true' ]]; then
    echo "##### installing comms";
    # mumble server
    cd ~
    git clone https://github.com/umurmur/umurmur.git
    cd umurmur
    ./autogen.sh
    ./configure
    make
    sudo cp -fvv src/umurmurd /usr/bin/umurmurd
    # mumble client
    cd ~
    go get -u layeh.com/barnard
    sudo mkdir -p /usr/share/alsa/
    sudo cp -fvv ~/nomad/alsa.conf /usr/share/alsa/alsa.conf
    cat << EOF > ~/asound.conf
pcm.!default {
 type hw
 card 1
}
ctl.!default {
 type hw
 card 1
}
EOF
    sudo cp -fvv ~/asound.conf /etc/asound.conf
    fi
    
    if [[ "$MINE" == 'true' ]]; then
	cd ~
	git clone https://github.com/revoxhere/duino-coin
	cd duino-coin
	python3 -m pip install -r requirements.txt
	python3 PC_Miner.py
    fi

    if [[ "$IOT" == "true" ]]; then
	cd ~
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
    sudo cp -fvv bin/arduino-cli /usr/local/bin/arduino-cli
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
    sudo chown pi:pi ~/.nomad
    echo "### NOMAD arduino-cli begin ###" >> ~/.nomad
    echo "function upload() { source config.sh; echo \"\$FQBN\"; arduino-cli compile --fqbn \$FQBN \`pwd\` && arduino-cli upload --port /dev/ttyUSB0 --fqbn \$FQBN \`pwd\`; }" >> ~/.nomad
    echo 'echo "upload -> upload sketch to device"' >> ~/.nomad
    echo "alias monitor='cat /dev/ttyUSB0'" >> ~/.nomad
    echo 'echo "monitor -> monitor serial traffic from device"' >> ~/.nomad
    echo "function arduino() { arduino-cli lib install \"$1\"; }" >> ~/.nomad
    echo 'echo "arduino <library> -> install arduino library"' >> ~/.nomad
    echo "function sketch() { arduino-cli sketch new \"\$1\" && echo 'export FQBN=\"\"' > \$1/config.sh && micro \$1/config.sh && micro \$1/\$1.ino; }" >> ~/.nomad
    echo 'echo "sketch <name> -> create new arduino sketch."' >> ~/.nomad
    echo "### NOMAD arduino-cli end ###" >> ~/.nomad
    fi
    echo "##### FINISHING #####";
    cd $here;
    if [[ "$DOMAINS" != "" ]]; then
	d=($DOMAINS);
	for ((i = 0; i < ${#d[@]}; ++i)); do
	    export MUMBLE=$(( $i + $MUMBLE + 1 ));
	    domain ${d[$i]};
	done
    fi
    domain 'localhost'
    sudo chown $USERNAME:$USERNAME ~/*;
    sudo chown $USERNAME:$USERNAME ~/.*;
    if [[ "$INIT" != 'false' ]]; then
	(echo "@reboot cd /home/pi/nomad && ./nomad.sh boot") | sudo crontab -
    fi
    echo "##### REBOOT TO RUN #####";
    echo "# v--- add to ~/.bashrc #";
    echo "#    source ~/.nomad    #";
    echo "# to load nomad tools.  #"
    echo "#####     DONE!     #####";
    
else
    debug 'init' "2"
    source /home/pi/nomad.conf
    if [[ -f nomad.lock ]]; then
	ruby exe/nomad.rb -I
    else
	debug 'init' "3"
	if [[ "$BOT" == 'true' ]]; then
	    ruby bin/cluster.rb &
	fi
	if [[ "$BONNET" == 'true' ]]; then
	    sudo ruby bin/bonnet.rb &
	fi
	if [[ "$MINE" == 'true' ]]; then
	    (cd /home/pi/duino-coin && python3 PC_Miner.py &)
	fi
	if [[ "$MUSH" == 'true' ]]; then
	    ruby bin/mud.rb &
	fi
	if [[ "$DEVS" == 'true' ]]; then
	    ruby bin/proxy_sub.rb &
	fi
	debug 'init' "4"
	files=$(shopt -s nullglob dotglob; echo run/*)
	if (( ${#files} )); then
	for f in run/*.sh;
	do
	    chmod +x $f
	    ./$f &
	    PIDS="$PIDS $!";
	done
	fi
	touch nomad.lock
	debug 'init' "5"
	if [[ "$BOX" != 'false' ]]; then
	    if [[ "`cat /var/lib/tor/nomad/hostname`" != "" ]]; then
		redis-cli set ONION "`cat /var/lib/tor/nomad/hostname`" > /dev/null;
	    fi
	    ruby exe/nomad.rb -i -s $PHONE_SID -k $PHONE_KEY;
	    PIDS="$PIDS $!";
	else
	    redis-cli del ONION > /dev/null;
	    ruby exe/nomad.rb -i -s $PHONE_SID -k $PHONE_KEY;
	fi
    fi
    exit 0;
fi
