#!/bin/bash

apt-get install python-software-properties
add-apt-repository ppa:avsm/ppa
apt-get update -y -f
apt-get install ocaml opam -y


mkdir -p /usr/src/unison/
cd /usr/src/unison/

curl -L -o unison https://github.com/TentativeConvert/Syndicator/raw/master/unison-binaries/unison-2.48.3
curl -L -o unison-fsmonitor https://github.com/TentativeConvert/Syndicator/raw/master/unison-binaries/unison-fsmonitor

chmod +x unison
mv unison /usr/bin/

chmod +x unison-fsmonitor
mv unison-fsmonitor /usr/bin/

echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
