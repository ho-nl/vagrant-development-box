#!/bin/bash

echo "🔥  Ensuring latest version of composer is installed"

set -e
[ -f "/usr/local/bin/composer" ] || php -r "readfile('https://getcomposer.org/installer');" \
    | php -- --install-dir=/usr/local/bin --filename=composer \
    && /usr/local/bin/composer self-update
