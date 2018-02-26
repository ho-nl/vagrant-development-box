#!/bin/bash

echo "🔥  Ensuring composer is installed"

set -e
[ -f "/usr/local/bin/composer" ] || php -r "readfile('https://getcomposer.org/installer');" \
    | php -- --install-dir=/usr/local/bin --filename=composer
