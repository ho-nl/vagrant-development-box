#!/usr/bin/env bash

if ! [ ${VAGRANT_REDIS_MEMORY} == 'false' ]; then
    echo "🔥  Setting redis memory to $VAGRANT_REDIS_MEMORY"   
    sudo sed -i "s/.*maxmemory .*/maxmemory ${VAGRANT_REDIS_MEMORY}/" /etc/redis/redis.conf
    sudo service redis restart
fi
