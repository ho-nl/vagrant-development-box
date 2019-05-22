#!/usr/bin/env bash

function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

PHP_V=$(php -v|awk '{ print $0 }'|awk -F\, '{ print $1 }')
CURRENT_PHP_VERSION=${PHP_V:4:3}
sudo service "php${CURRENT_PHP_VERSION}-fpm" stop

if [ $VAGRANT_PHP_VERSION == "7.1" ]; then
    if [ $(program_is_installed php7.1) == 0 ]; then
        echo "🔥  Installing PHP 7.1"

        sudo apt-get install -y python-software-properties
        sudo add-apt-repository -y ppa:ondrej/php
        sudo apt-get update -y

        sudo apt-get --assume-yes install php7.1 php7.1-bcmath php7.1-cli php7.1-common php7.1-curl php7.1-dev php7.1-fpm php7.1-gd php7.1-imap php7.1-intl php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-pspell php7.1-readline php7.1-soap php7.1-sybase php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-zip php7.1-imagick

        sudo rm /etc/php/7.1/fpm/pool.d/www.conf
        sudo cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.1/fpm/pool.d/www.conf
    fi
fi

if [ $VAGRANT_PHP_VERSION == "7.2" ]; then
    if [ $(program_is_installed php7.2) == 0 ]; then
        echo "🔥  Installing PHP 7.2"

        sudo apt-get install -y python-software-properties
        sudo add-apt-repository -y ppa:ondrej/php
        sudo apt-get update -y

        sudo apt-get --assume-yes install php7.2 php7.2-bcmath php7.2-cli php7.2-common php7.2-curl php7.2-dev php7.2-fpm php7.2-gd php7.2-imap php7.2-intl php7.2-json php7.2-ldap php7.2-mbstring php7.2-mysql php7.2-odbc php7.2-opcache php7.2-pgsql php7.2-pspell php7.2-readline php7.2-soap php7.2-sybase php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-zip php7.2-imagick

        sudo rm /etc/php/7.2/fpm/pool.d/www.conf
        sudo cp /etc/php/7.0/fpm/pool.d/www.conf /etc/php/7.2/fpm/pool.d/www.conf
    fi
fi

# Setup separate xdebug php-fpm instance if not done yet
FPM_XDEBUG_CONF_DIR="/etc/php/${VAGRANT_PHP_VERSION}/fpm-xdebug"
if [ ! -d "$FPM_XDEBUG_CONF_DIR" ]; then
  echo "🔥  Setting up xdebug php-fpm instance"

  cp -a "/etc/php/${VAGRANT_PHP_VERSION}/fpm" "$FPM_XDEBUG_CONF_DIR"

  # Configure php-fpm.conf, www pool
  sed -i "s/pid =.*/pid = \/run\/php\/php$VAGRANT_PHP_VERSION-fpm-xdebug.pid/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"
  sed -i "s/error_log =.*/error_log = \/var\/log\/php$VAGRANT_PHP_VERSION-fpm-xdebug.log/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"
  sed -i "s/include=.*/include=\/etc\/php\/$VAGRANT_PHP_VERSION\/fpm-xdebug\/pool.d\/*.conf/" "$FPM_XDEBUG_CONF_DIR/php-fpm.conf"

  sed -i "s/listen =.*/listen = 127.0.0.1:9099/" "$FPM_XDEBUG_CONF_DIR/pool.d/www.conf"
  sed -i "s/slowlog =.*/slowlog = \/var\/log\/php-fpm\/php-slow-xdebug.log/" "$FPM_XDEBUG_CONF_DIR/pool.d/www.conf"

  # Setup systemd service
  SYSTEMD_CONFIG="[Unit]
Description=The PHP $VAGRANT_PHP_VERSION FastCGI Process Manager (xdebug)
Documentation=man:php-fpm$VAGRANT_PHP_VERSION(8)
After=network.target

[Service]
Type=notify
PIDFile=/run/php/php$VAGRANT_PHP_VERSION-fpm-xdebug.pid
Environment=\"PHP_INI_SCAN_DIR=/etc/php/$VAGRANT_PHP_VERSION/fpm-xdebug/conf.d\"
ExecStart=/usr/sbin/php-fpm$VAGRANT_PHP_VERSION --nodaemonize --fpm-config /etc/php/$VAGRANT_PHP_VERSION/fpm-xdebug/php-fpm.conf
ExecReload=/bin/kill -USR2 \$MAINPID

[Install]
WantedBy=multi-user.target
";
  echo -n "$SYSTEMD_CONFIG" > "/lib/systemd/system/php$VAGRANT_PHP_VERSION-fpm-xdebug.service"
  systemctl enable php$VAGRANT_PHP_VERSION-fpm-xdebug
  systemctl start php$VAGRANT_PHP_VERSION-fpm-xdebug

fi

# Start the correct FPM daemon
echo "🔥  Switching to PHP $VAGRANT_PHP_VERSION"
sudo hypernode-switch-php $VAGRANT_PHP_VERSION &>/dev/null
sudo service "php$VAGRANT_PHP_VERSION-fpm" start

