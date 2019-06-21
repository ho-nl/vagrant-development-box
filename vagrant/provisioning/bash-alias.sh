#!/usr/bin/env bash

AS_USER="sudo -u ${VAGRANT_USER}"
HOME_DIR=$(getent passwd ${VAGRANT_USER} | cut -d ':' -f6)

PHP_V=$(php -v|awk '{ print $0 }'|awk -F\, '{ print $1 }')
PHP_VERSION=${PHP_V:4:3}
[ "$PHP_VERSION" == "5.5" ] && MODULES_DIR="/usr/lib/php/20121212/"
[ "$PHP_VERSION" == "5.6" ] && MODULES_DIR="/usr/lib/php/20131226/"
[ "$PHP_VERSION" == "7.0" ] && MODULES_DIR="/usr/lib/php/20151012/"
[ "$PHP_VERSION" == "7.1" ] && MODULES_DIR="/usr/lib/php/20160303/"
[ "$PHP_VERSION" == "7.2" ] && MODULES_DIR="/usr/lib/php/20170718/"

echo "🔥  Setting up bash aliases"

CONFIG="
alias phpd='php -dzend_extension=$MODULES_DIR/xdebug.so -dxdebug.remote_autostart=On'
alias curld='curl --cookie "XDEBUG_SESSION=PhpStorm" -o /dev/null'
";

rm -f "${HOME_DIR}/.bash_aliases";
$AS_USER touch "${HOME_DIR}/.bash_aliases";
echo -n "${CONFIG}" >> "${HOME_DIR}/.bash_aliases"

echo $(cat ${HOME_DIR}/.bash_aliases)
