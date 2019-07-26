#!/bin/bash

PHP_VERSION=${VAGRANT_PHP_VERSION}

echo "🔥  Ensuring latest version of composer is installed"

set -e
[ -f "/usr/local/bin/composer" ] || php -r "readfile('https://getcomposer.org/installer');" \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && /usr/local/bin/composer self-update

# Remove PHP CLI memory limit to work around composer's extreme memory usage when calculating dependencies
[ -f "/etc/php/${PHP_VERSION}/cli/conf.d/magweb.ini" ] \
    && sed -i "s/memory_limit.*/memory_limit = -1/" "/etc/php/${PHP_VERSION}/cli/conf.d/magweb.ini" \
    || true
