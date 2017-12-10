#!/usr/bin/env bash

PHP_V=$(php -v|awk '{ print $0 }'|awk -F\, '{ print $1 }')
PHP_VERSION=${PHP_V:4:3}

[ "$PHP_VERSION" == "5.5" ] && MODULES_DIR="/usr/lib/php/20121212/"
[ "$PHP_VERSION" == "5.6" ] && MODULES_DIR="/usr/lib/php/20131226/"
[ "$PHP_VERSION" == "7.0" ] && MODULES_DIR="/usr/lib/php/20151012/"
[ "$PHP_VERSION" == "7.1" ] && MODULES_DIR="/usr/lib/php/20160303/"
[ "$PHP_VERSION" == "7.2" ] && MODULES_DIR="/usr/lib/php/20170718/"

[ "$PHP_VERSION" == "5.5" ] && XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.5.5.tgz"
[ "$PHP_VERSION" == "5.6" ] && XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.5.5.tgz"
[ "$PHP_VERSION" == "7.0" ] && XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.5.5.tgz"
[ "$PHP_VERSION" == "7.1" ] && XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.6.0alpha1.tgz"
[ "$PHP_VERSION" == "7.2" ] && XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.6.0alpha1.tgz"

PHP_CONF_DIR="/etc/php/$PHP_VERSION"

if ! [ ${VAGRANT_XDEBUG} == 'false' ]; then
    echo "🔥  Enabling Xdebug for PHP $PHP_VERSION"

    # Download the configured release
    if [ ! -f ${MODULES_DIR}xdebug.so ]; then
        echo "🔥  Installing Xdebug for PHP $PHP_VERSION in $MODULES_DIR ($XDEBUG_RELEASE)"

        # Install the required package(s)
        apt-get update
        apt-get install ${PHP_VERSION}-dev -yy

        # Unpack Xdebug
        wget -q -nc -O /tmp/xdebug.tgz $XDEBUG_RELEASE
        cd /tmp
        tar -xvzf xdebug.tgz
        cd xdebug-*

        # Build Xdebug from source
        phpize${PHP_VERSION}
        ./configure --with-php-config=$(which php-config$PHP_VERSION)
        make

        cp -f modules/xdebug.so $MODULES_DIR

        rm -rf /tmp/xdebug*
    fi

    # Configure PHP to load xdebug.so
    for i in fpm cli; do
        EXTENSION_CONFIG="zend_extension = ${MODULES_DIR}xdebug.so
xdebug.max_nesting_level=2000
xdebug.remote_enable=1
xdebug.remote_host=33.33.33.1
xdebug.remote_port=9000
"
        rm -f ${PHP_CONF_DIR}/${i}/conf.d/10-xdebug.ini;
        touch ${PHP_CONF_DIR}/${i}/conf.d/10-xdebug.ini
        echo -n "$EXTENSION_CONFIG" > ${PHP_CONF_DIR}/${i}/conf.d/10-xdebug.ini

    done

    if [ -f ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini ]; then
        mv ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini.disabled
    fi
else
    echo "🔥  Disabling Xdebug"

    if [ -f ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini.disabled ]; then
        mv ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini.disabled ${PHP_CONF_DIR}/fpm/conf.d/fpminspector.ini
    fi

    for i in fpm cli; do
        if [ -f ${PHP_CONF_DIR}/${i}/conf.d/10-xdebug.ini ]; then
            rm -f ${PHP_CONF_DIR}/${i}/conf.d/10-xdebug.ini
        fi
    done
fi


sudo service "php$PHP_VERSION-fpm" start
service nginx restart
