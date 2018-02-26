#!/bin/bash

if ! type "unison-fsmonitor" > /dev/null; then

    echo "🔥  Ensuring Unison is installed"

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:eugenesan/ppa -y
    sudo apt-get install unison

    curl -L -o unison-fsmonitor https://github.com/TentativeConvert/Syndicator/raw/master/unison-binaries/unison-fsmonitor

    chmod +x unison-fsmonitor
    mv unison-fsmonitor /usr/bin/

    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi
