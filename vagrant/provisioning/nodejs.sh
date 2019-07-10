#!/usr/bin/env bash
AS_USER="sudo -u ${VAGRANT_USER}"

# @todo implement better check, to actually check the version.
if ! [ -f /etc/apt/preferences.d/node ]; then
    echo "🔥  Installing nodejs 9"
    echo "Package: *
Pin: release o=Node Source
Pin-priority: 900" >>/etc/apt/preferences.d/node
    curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

if ! [ -d /data/web/.npm-global ]; then
    echo "🔥  Allowing nodejs module installation in userspace"

    $AS_USER mkdir /data/web/.npm-global
    npm config set prefix '/data/web/.npm-global'
fi

if ! [ -f /data/web/.bash_profile ]; then
    echo "🔥  Adding nodejs packages to .bash_profile"
    $AS_USER touch /data/web/.bash_profile
    echo 'export PATH=~/.npm-global/bin:$PATH' >>/data/web/.bash_profile

    # Ensure our bashrc keeps working, due to .profile (which normally sources bashrc) isn't read if .bash_profile exists
    SOURCE_BASHRC="# include .bashrc if it exists
    if [ -f \"\$HOME/.bashrc\" ]; then
	. \"\$HOME/.bashrc\"
    fi"
    echo "$SOURCE_BASHRC" >> /data/web/.bash_profile
fi
