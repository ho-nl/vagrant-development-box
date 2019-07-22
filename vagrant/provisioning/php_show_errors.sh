#!/usr/bin/env bash

PHP_VERSION=${VAGRANT_PHP_VERSION}

echo "🔥  Ensuring PHP errors are shown in the browser"

for i in fpm-xdebug fpm cli; do
    CONFIG="display_errors = On
display_startup_errors = On
";

    rm -f /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini;
    touch /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini
    echo -n "${CONFIG}" > /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini
done

# Restart PHP
systemctl restart php${PHP_VERSION}-fpm
systemctl restart php${PHP_VERSION}-fpm-xdebug
