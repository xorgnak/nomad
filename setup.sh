#!/bin/bash


if [[ $1 == '' ]]; then
    DIR='..'
else
    DIR=$1
fi

DISTRO_NAME='nomadic'
DISTRO_VARIANT='local'
DISTRO_PRETTY_NAME='Nomadic Linux'
DISTRO_HOSTNAME='nomad'
DISTRO_PACKAGES='git emacs emacs-goodies-el vim ruby-full inotify-tools screen redis-server openssh-server tor qrencode nmap arp-scan grep wpasupplicant macchanger tshark wifite netcat ii chntpw'
DISTRO_GEMS='pry sinatra redis-objects cinch gmail'

X="[\033[0;34m$DISTRO_NAME\033[0m]"

echo -e "$X HOSTNAME"
echo $DISTRO_HOSTNAME > /etc/hostname

echo -e "$X DEBS"
apt-get -qq update
apt-get -y -qq install $SCRIPT_PACKAGES $DISTRO_PACKAGES
echo -e "$X GEMS"
gem install $DISTRO_GEMS 2>1 /dev/null

echo -e "$X SCREEN"
cat << END > $DIR/.screenrc 
shell -${SHELL}
caption always "[ %t(%n) ] %w"
defscrollback 1024
startup_message off
hardstatus on
hardstatus alwayslastline
screen -t emacs 0 emacs -nw --visit ~/index.org
screen -t bash 1 bash
screen -t pry 2 pry
select 0
END
chown $USERNAME:$USERNAME $DIR/.screenrc

echo -e "$X INDEX"
cat << END > $DIR/index.org
#+TITLE: Nomadic Linux.
#+TODO: TODO(t!/@) ACTION(a!/@) WORKING(w!/@) | ACTIVE(f!/@) DELEGATED(D!/@) DONE(X!/@)
#+OPTIONS: stat:t html-postamble:nil H:1 num:nil toc:t \n:nil ::nil |:t ^:t f:t tex:t

* Welcome!
  Nomadic linux is built to cope with disasters.  It has a simple set of tools designed to get you up and running quickly and consistantly.  Keep a Spare usb stick in your pocket - you never know when it will come in handy.

* Tools
  - git: The version control system of the future.
  - emacs: The gnu text editor.
  - vim: It's always there.
  - ruby: A dynamic, object oriented, interpreted language.
  - python: A compiled high level language.
  - inotify: Kernel file event notification tools.
  - screen: The gnu terminal multiplexer.
  - redis: A next generation NOsql database.
  - tor: The tor network client tools.
  - nmap: A network analysis tool.
  - tshark: A packet analysis tool.
  - wifite: A simple wireless network decrypter.
  - netcat: The linux network swiss army knife.
  - ii: A tiny filesystem based irc client suitable for scripting.

* Leah
  The Leah tool allows single administrator access to common tools used to administer standalone systems (desktops and laptops) and networks.  It can be thought of as a "smart sudo" or an easy way to not grant privledges unnecessarily on a system.
  - lan: scans the local area network, and performs an OS fingerprint on the attached devices.
  - wifi: connects the local wireless card to an ssid and key, or an existing ssid/key pair.
  - svc: adds a port to be hosted as a hidden service.
  - mnt: mounts a local device.

* Org Mode for fun and profit
  Nomadic linux believes in staying organized.  Org mode keeps notes well organized. Nomadic linux also integrates lots of other tools to automate the process of exporting these files.

END
chown $USERNAME:$USERNAME $DIR/index.org

echo -e "$X PROMPT"
cat << 'END' > $DIR/.prompt
#  Customize BASH PS1 prompt to show current GIT repository and branch.
#  by Mike Stewart - http://MediaDoneRight.com
#  SETUP CONSTANTS
#  Bunch-o-predefined colors.  Makes reading code easier than escape sequences.
#  I don't remember where I found this.  o_O
# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"


# This PS1 snippet was adopted from code for MAC/BSD I saw from: http://allancraig.net/index.php?option=com_content&view=article&id=108:ps1-export-command-for-git&catid=45:general&Itemid=96
# I tweaked it to work on UBUNTU 11.04 & 11.10 plus made it mo' better

export PS1=$Green$Time12h$Color_Off'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    # @4 - Clean repository - nothing to commit
    echo "'$Green'"$(__git_ps1 " (%s)"); \
  else \
    # @5 - Changes to working tree
    echo "'$IRed'"$(__git_ps1 " {%s}"); \
  fi) '$BYellow$PathShort$Color_Off'\$ "; \
else \
  # @2 - Prompt when not in GIT repo
  echo " '$Yellow$PathShort$Color_Off'\$ "; \
fi)'

END
chown $USERNAME:$USERNAME $DIR/.prompt

echo -e "$X BASH"
if [[ $2 == '--live' ]]; then
cat << 'END' >> $DIR/.bashrc
source ~/.prompt
function leah() { sudo su -c "source /root/leah.sh && $*"; }
END
else
cat << 'END' >> $DIR/.bashrc
source ~/.prompt
function leah() { su -c "source /root/leah.sh && $*"; }
END
fi
chown $USERNAME:$USERNAME $DIR/.bashrc

echo -e "$X PROFILE"
cat << END >> $DIR/.profile
screen
END
chown $USERNAME:$USERNAME $DIR/.profile

echo -e "$X LEAH"
cat << 'END' > /root/leah.sh
#!/bin/bash
AUTOSTART=~/.autostart.sh
ANON="false"
PS1="#> "
function lan() {
    IP_REGEXP="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
    IPs=`sudo arp-scan --localnet | grep -E -o $IP_REGEXP`
    nmap -O -F -v $IPs
}
function wifi() {
    WPA=/etc/wpa_supplicant/$1.conf
    if [[ $ANON == "true" ]]; then
	echo "Randomizing MAC address..."
	macchanger -r wlan0
    fi
    if [[ $1 != ''  ]]; then
	if [[ $2 != '' ]]; then
	    echo "Generating $1 configuration..."
	    if [[ $3 != '' ]]; then
		echo "Generating Network configuration..."
		wpa_passphrase $2 $3 > $WPA
	    else
		echo -e "network={\nssid="$2"\nkey_mgmt=NONE\n}\n" > $WPA
	    fi
	else
	    echo "Using existing configuration for $1:"
	fi
	cat $WPA
	### 3
	echo "Starting Wireless Driver..."
	wpa_supplicant -Dwext -iwlan0 -c$WPA &
	echo "Starting DHCP Client..."
	dhclient -v -4 wlan0
    fi    
}

function kill_wifi() {
    pkill NetworkManager
    pkill wpa_supplicant
    pkill dhclient
    ifconfig
}

function svc() {
  pkill tor
cat <<EXX >> /etc/tor/torrc
HiddenServiceDir /var/lib/tor/$1/
HiddenServicePort $1 127.0.0.1:$1
EXX
  tor &
  cat /var/lib/tor/$1/hostname
}

function mnt() {
    mkdir -p /mnt/sd
    mount /dev/sdb2 /mnt/$1
    echo "DEVICE: /dev/$1 MOUNTED: /mnt/$1"
    ls -lha /mnt/$1
}

echo -e "############################\n# Dont do anything stupid. #\n############################"
END

##
# TRAMP STAMP

echo -e "$X ISSUE"

cat << END > /etc/issue
The programs included with the Debian GNU/Linux system are free software; the exact distribution terms for each program are described in the individual files in /usr/share/doc/*/copyright. Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law.

         ############ NOMADIC #############
         #########  #######################
         ########    ######################
         ########    ########  +###########
         #########  #@  ####    ###########
         ##########   ; +###    ###########
         #########+   .  ####  ;@  ########
         #########     + +####      #######
         #########        ####      #######
         #########      #####;    # ;######
         #######:  +     ####       #######
         ######   ##     ###  +    ########
         #####  ####,    #.  ##:   ;#######
         ######; ###    ##  ###+   ########
         ####### ##;    ### +##    ########
         ######## #      ### ##    ########
         ########    :   ###.;.     #######
         #########   ##  ####   #   #######
         #########   ##,  ###: .##  #######
         #########  ####  ###.  ##, ;######
         #########   ###, +##   ###  ######
         ########: . :###  ##   ###: ######
         #########  # ###: ## .# ###  #####
         ##################################
         ############## LINUX #############
   
$DISTRO_PRETTY_NAME 
(`uname -a`)
This image was born on: `date`
May the force be with you...
END
echo -e "$X DONE!"
