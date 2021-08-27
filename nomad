#!/bin/sh

if [ "$1" = 'install' ]; then
    rm -f nomadic/exe/*~
    rm -f nomadic/lib/*~
    sudo cp -fRvv nomadic /usr/share/
    sudo cp -fvv nomad /usr/bin/
    sudo ./nomadic/exe/nomad.sh $*
    (sudo crontab -l; echo "@reboot /usr/bin/nomad") | sudo crontab -
    sudo service nginx restart
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
