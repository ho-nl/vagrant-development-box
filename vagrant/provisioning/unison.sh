#!/bin/bash

apt-get install python-software-properties
add-apt-repository ppa:avsm/ppa
apt-get update -y -f
apt-get install ocaml opam -y


mkdir -p /usr/src/unison/
cd /usr/src/unison/

wget https://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-2.48.4/unison-2.48.4.tar.gz -O unison.tar.gz
tar xzvf unison.tar.gz  --strip-components 1
make UISTYLE=text || true

chmod +x unison
mv unison /usr/bin/

curl -L -o unison-fsmonitor https://github.com/TentativeConvert/Syndicator/raw/master/unison-binaries/unison-fsmonitor

chmod +x unison-fsmonitor
mv unison-fsmonitor /usr/bin/

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
