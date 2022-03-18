
sudo apt-get install build-essential libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev subversion git-core autoconf postgresql pgadmin3 curl zlib1g-dev libxml2-dev libxslt1-dev libyaml-dev nmap tshark

sudo curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall

if [[ ! -d "~/berryconda3" || ! -d "~/berryconda2" ]]; then
if [[ "$1" == '1' ]]; then
./exe/Berryconda3-2.0.0-Linux-armv7l.sh
else
./exe/Berryconda3-2.0.0-Linux-armv6l.sh
fi
fi

conda install jupyter


echo -e "##### war box" >> ~/.nomad
echo -e "alias shark='sudo tshark -i'" >> ~/.nomad
echo -e "alias scan='sudo nmap -s'" >> ~/.nomad
echo -e "alias notebook='jupyter-notebook'" >> ~/.nomad
echo -e "echo 'shark <dev> -> listen to network traffic going over dev'" >> ~/.nomad
echo -e "echo 'scan <host> -> scan host'" >> ~/.nomad
echo -e "echo 'msfconsole -> open the metasploit framework'" >> ~/.nomad
echo -e "echo 'notebook -> open a jupyter notebook'" >> ~/.nomad
