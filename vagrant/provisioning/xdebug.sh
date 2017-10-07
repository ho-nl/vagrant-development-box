which php5 && PHP_VERSION="php5" || /bin/true
which php7.0 && PHP_VERSION="php7.0" || /bin/true

[ "$PHP_VERSION" == "php5" ] && MODULES_DIR="/usr/lib/php5/20121212/"
[ "$PHP_VERSION" == "php7.0" ] && MODULES_DIR="/usr/lib/php/20151012/"

[ "$PHP_VERSION" == "php5" ] && PHP_DIR="/etc/php5/"
[ "$PHP_VERSION" == "php7.0" ] && PHP_DIR="/etc/php/7.0/"

if ! [ ${VAGRANT_XDEBUG} == 'false' ]; then
    XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.5.5.tgz"
    echo "Enabling Xdebug"

    # Install Xdebug for retrieving extended debug information and
    # stacktraces from your development environment.

    if [ -z $PHP_VERSION ]; then
        echo "No supported PHP version found for this xdebug installation script. Skipping.."
    break
    fi

    # Download the configured release
    if [ ! -f ${MODULES_DIR}xdebug.so ]; then
        echo "Installing Xdebug"

        # Install the required package(s)
        apt-get update
        apt-get install ${PHP_VERSION}-dev -yy

        # Unpack Xdebug
        wget -q -nc -O /tmp/xdebug.tgz $XDEBUG_RELEASE
        cd /tmp
        tar -xvzf xdebug.tgz
        cd xdebug-*

        # Build Xdebug from source
        /usr/bin/phpize
        ./configure
        make

        cp -f modules/xdebug.so $MODULES_DIR
    fi

    # Configure PHP to load xdebug.so
    for i in fpm cli; do
        EXTENSION_CONFIG="zend_extension = ${MODULES_DIR}xdebug.so
xdebug.max_nesting_level=2000
xdebug.remote_enable=1
xdebug.remote_host=33.33.33.1
xdebug.remote_port=9000
"
    rm ${PHP_DIR}${i}/conf.d/10-xdebug.ini;
    touch ${PHP_DIR}${i}/conf.d/10-xdebug.ini
    echo -n "$EXTENSION_CONFIG" > ${PHP_DIR}${i}/conf.d/10-xdebug.ini

    done

else
    echo "Disabling Xdebug"

    for i in fpm cli; do
        if [ -f ${PHP_DIR}${i}/conf.d/10-xdebug.ini ]; then
            rm ${PHP_DIR}${i}/conf.d/10-xdebug.ini
        fi
    done
fi

# Restart PHP and Nginx
[ "$PHP_VERSION" == "php5" ] && service php5-fpm restart
[ "$PHP_VERSION" == "php7.0" ] && service php7.0-fpm restart
service nginx restart
