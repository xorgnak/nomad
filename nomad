#!/bin/sh

if [ "$1" = 'install' ]; then
    rm -f nomadic/exe/*~
    rm -f nomadic/exe/*~
    sudo cp -fRvv nomadic /usr/share/
    sudo cp -fvv nomad /usr/bin/
elif [ "$1" = 'nomadic' ]; then
    sudo ./nomadic/exe/nomad.sh
elif [ "$1" = 'autostart' ]; then
    (crontab -l; echo "@reboot /usr/bin/nomad") | crontab -
elif [ "$1" = 'kiosk' ]; then
    mkdir -p ~/.config/autostart
    cat << END > ~/.config/autostart/chromium-browser.desktop
[Desktop Entry]	 
Type=Application
Exec=chromium-browser
END
    cat << END > ~/.config/autostart/terminator.desktop
[Desktop Entry]
Type=Application
Exec=terminator
END
else
    ruby /usr/share/nomadic/exe/nomad.rb $*
fi
