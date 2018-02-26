#!/bin/bash

echo "";
echo "";
echo "
🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥
🔥                                                               🔥
🔥  #########     #######        #         #######    ##    ##   🔥
🔥          ##                  ###       ##          ##    ##   🔥
🔥       ####     #######      ## ##     ##           ########   🔥
🔥        ##                  ##   ##     ##          ##    ##   🔥
🔥         ##     #######    ##     ##     #######    ##    ##   🔥
🔥                                                               🔥
🔥                          Vagrant Box                          🔥
🔥                                                               🔥
🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥
"
echo "";
echo "";

echo "🙏  \$ ssh ${VAGRANT_USER}@${VAGRANT_HOSTNAME}"
echo "";

HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)
MYSQLPASSWORD=$(awk -F "=" '/password/ {print $2}' ${HOME_DIR}/.my.cnf | sed -e 's/^[ \t]*//')
echo "🙏  mysql host:${VAGRANT_HOSTNAME} username:${VAGRANT_USER} password:${MYSQLPASSWORD}"
echo "🙏  http://${VAGRANT_HOSTNAME}";

echo "";

echo "Setup M2: https://github.com/ho-nl/vagrant-development-box#magento-2-configuration";
echo "Setup M1: https://github.com/ho-nl/vagrant-development-box#magento-1-configuration";
