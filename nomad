#!/bin/sh

if [ "$1" = 'install' ]; then
    rm -f nomadic/exe/*~
    rm -f nomadic/lib/*~
    sudo cp -fRvv nomadic /usr/share/
    sudo cp -fvv nomad /usr/bin/
    sudo ./nomadic/exe/nomad.sh
    (crontab -l; echo "@reboot /usr/bin/nomad") | crontab -
    sudo cat << END > /etc/nginx/sites-enabled/default
server {
       listen 80 ;
       listen [::]:80;
       server_name localhost `cat /etc/hostname`.local;
       location / {
         proxy_pass_header  Set-Cookie;
         proxy_set_header   Host               $host;
         proxy_set_header   X-Real-IP          $remote_addr;
         proxy_set_header   X-Forwarded-Proto  $scheme;
         proxy_set_header   X-Forwarded-For    $proxy_add_x_forwarded_for;
         proxy_pass http://127.0.0.1:4567/;
         proxy_buffering off;
       }
}
END
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
