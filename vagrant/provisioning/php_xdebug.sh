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

service nginx stop

if [ -f "/lib/systemd/system/php$PHP_VERSION-fpm-xdebug.service" ]; then
    systemctl stop "php$PHP_VERSION-fpm-xdebug"
fi

# Download and compile the configured release
if [ ! -f ${MODULES_DIR}xdebug.so ]; then
    echo "🔥  Installing Xdebug for PHP $PHP_VERSION in $MODULES_DIR ($XDEBUG_RELEASE)"

    # Install the required package(s)
    apt-get update
    apt-get install "${PHP_VERSION}"-dev -yy

    # Unpack Xdebug
    wget -q -nc -O /tmp/xdebug.tgz $XDEBUG_RELEASE
    cd /tmp
    tar -xvzf xdebug.tgz
    cd xdebug-*

    # Build Xdebug from source
    phpize"${PHP_VERSION}"
    PHP_CONFIG=$(command -v "php-config$PHP_VERSION")
    ./configure --with-php-config="$PHP_CONFIG"
    make

    cp -f modules/xdebug.so $MODULES_DIR

    rm -rf /tmp/xdebug*
fi

# Setup separate xdebug php-fpm instance
FPM_XDEBUG_CONF_DIR="/etc/php/${PHP_VERSION}/fpm-xdebug"
if [ ! -d "$FPM_XDEBUG_CONF_DIR" ]; then
  echo "🔥  Setting up Xdebug php$PHP_VERSION-fpm instance"

  cp -a "/etc/php/${PHP_VERSION}/fpm" "$FPM_XDEBUG_CONF_DIR"

  # Configure php-fpm.conf, www pool
  sed -i "s/pid =.*/pid = \/run\/php\/php$PHP_VERSION-fpm-xdebug.pid/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"
  sed -i "s/error_log =.*/error_log = \/var\/log\/php$PHP_VERSION-fpm-xdebug.log/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"
  sed -i "s/include=.*/include=\/etc\/php\/$PHP_VERSION\/fpm-xdebug\/pool.d\/*.conf/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"

  sed -i "s/listen =.*/listen = 127.0.0.1:9099/" "$FPM_XDEBUG_CONF_DIR/pool.d/www.conf"
  sed -i "s/slowlog =.*/slowlog = \/var\/log\/php-fpm\/php-slow-xdebug.log/" "$FPM_XDEBUG_CONF_DIR/pool.d/www.conf"

  # Setup systemd service
  SYSTEMD_CONFIG="[Unit]
Description=The PHP $PHP_VERSION FastCGI Process Manager (xdebug)
Documentation=man:php-fpm$PHP_VERSION(8)
After=network.target

[Service]
Type=notify
PIDFile=/run/php/php$PHP_VERSION-fpm-xdebug.pid
Environment=\"PHP_INI_SCAN_DIR=/etc/php/$PHP_VERSION/fpm-xdebug/conf.d\"
ExecStart=/usr/sbin/php-fpm$PHP_VERSION --nodaemonize --fpm-config /etc/php/$PHP_VERSION/fpm-xdebug/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID

[Install]
WantedBy=multi-user.target
";
  echo -n "$SYSTEMD_CONFIG" > "/lib/systemd/system/php$PHP_VERSION-fpm-xdebug.service"
fi

# Disable fpm inspector, causes issues with mapping to local file in PhpStorm
echo "🔥  Disabling fpm inspector for xdebug"
if [ -f "$FPM_XDEBUG_CONF_DIR/conf.d/fpminspector.ini" ]; then
  mv "$FPM_XDEBUG_CONF_DIR/conf.d/fpminspector.ini" "$FPM_XDEBUG_CONF_DIR/conf.d/fpminspector.ini.disabled"
fi


# Configure xdebug for CLI and fpm-xdebug
for i in fpm-xdebug cli; do
    EXTENSION_CONFIG="xdebug.max_nesting_level=2000
xdebug.remote_enable=1
xdebug.remote_host=33.33.33.1
xdebug.remote_port=9000
"
    rm -f "${PHP_CONF_DIR}"/${i}/conf.d/10-xdebug.ini;
    touch "${PHP_CONF_DIR}"/${i}/conf.d/10-xdebug.ini
    echo -n "$EXTENSION_CONFIG" > "${PHP_CONF_DIR}"/${i}/conf.d/10-xdebug.ini
done

# Clean possible left over file if xdebug was already enabled
rm -f "${PHP_CONF_DIR}"/fpm/conf.d/10-xdebug.ini;

# Only load module by default for fpm-xdebug, CLI will load through command line option using an alias
echo "zend_extension = ${MODULES_DIR}xdebug.so" >> "${PHP_CONF_DIR}"/fpm-xdebug/conf.d/10-xdebug.ini;

if [ -f "${PHP_CONF_DIR}"/fpm/conf.d/fpminspector.ini ]; then
    mv "${PHP_CONF_DIR}"/fpm/conf.d/fpminspector.ini "${PHP_CONF_DIR}"/fpm/conf.d/fpminspector.ini.disabled
fi

# Setup nginx to use xdebug php-fpm backend when XDEBUG_SESSION cookie is set
NGINX_XDEBUG_MAP="# Map to appropriate php-fpm backend depending on xdebug cookie
map \$cookie_XDEBUG_SESSION \$phpfpm_backend {
    default 127.0.0.1:9000;
    \"~*[a-z]+\" 127.0.0.1:9099;
}
"
echo -n "$NGINX_XDEBUG_MAP" > /etc/nginx/xdebug_cookie_map.conf
grep xdebug_cookie_map /etc/nginx/nginx.conf || sed -i "/include \/etc\/nginx\/app\/http.*/ a \ \ \ \ include /etc/nginx/xdebug_cookie_map.conf;" /etc/nginx/nginx.conf
sed -i "s/set \$fastcgi_pass.*/set \$fastcgi_pass \$phpfpm_backend;/" /etc/nginx/handlers.conf

echo "🔥  Enabling and starting Xdebug php$PHP_VERSION-fpm service"
systemctl enable "php$PHP_VERSION-fpm-xdebug"
systemctl start "php$PHP_VERSION-fpm-xdebug"

echo "🔥  Starting nginx service"
# Change back to home dir first, as current directory is (or might be) removed, triggering a
# getcwd() fatal error
cd
service nginx start
