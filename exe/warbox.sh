
if [[ ! -d "~/berryconda3" || ! -d "~/berryconda2" ]]; then
if [[ "$1" == '1' ]]; then
./exe/Berryconda3-2.0.0-Linux-armv7l.sh
else
./exe/Berryconda3-2.0.0-Linux-armv6l.sh
fi
fi

conda install jupyter

