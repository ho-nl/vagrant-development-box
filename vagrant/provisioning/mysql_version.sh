#!/usr/bin/env bash

MYSQL_CURRENT_VERSION=$(mysql --version|awk '{ print $5 }'|awk -F\, '{ print $1 }')
HOME_DIR=$(getent passwd app | cut -d ':' -f6)
MYSQL_PASSWORD=$(awk -F "=" '/password/ {print $2}' ${HOME_DIR}/.my.cnf | sed -e 's/^[ \t]*//');

if [ $VAGRANT_MYSQL_VERSION == '5.7' ]; then
    if [ ${MYSQL_CURRENT_VERSION:0:3} == '5.7' ]; then
        echo "MySQL version is already 5.7"
    else
        echo "🔥  Upgrading to MySQL $VAGRANT_MYSQL_VERSION (downgrade not possible)"

        MYSQL_PASSWORD=$(awk -F "=" '/password/ {print $2}' ${HOME_DIR}/.my.cnf | sed -e 's/^[ \t]*//')

        wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
        sudo dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
        sudo apt-get --assume-yes update

        sudo rm -f /etc/init.d/mysql.distrib
        # Comment out obsolete config variables
        sudo sed -e '/myisam-recover/ s/^#*/#/' -i /etc/mysql/my.cnf
        sudo sed -e '/thread_concurrency/ s/^#*/#/' -i /etc/mysql/conf.d/mysql-master.cnf
        sudo sed -e '/innodb_additional_mem_pool_size/ s/^#*/#/' -i /etc/mysql/conf.d/mysql-master.cnf

        sudo apt-get --assume-yes install percona-server-server-5.7

        sudo service mysql start

        sleep 3

        # Upgrade MySQL
        sudo mysql_upgrade -u app -p$MYSQL_PASSWORD
    fi
fi
