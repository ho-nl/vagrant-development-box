XDEBUG_RELEASE="https://xdebug.org/files/xdebug-2.5.0rc1.tgz"
echo "Ensuring Xdebug is installed"
 
# Install Xdebug for retrieving extended debug information and
# stacktraces from your development environment.
which php5 && PHP_VERSION="php5" || /bin/true
which php7.0 && PHP_VERSION="php7.0" || /bin/true
 
if [ -z $PHP_VERSION ]; then
    echo "No supported PHP version found for this xdebug installation script. Skipping.."
break
fi
 
# Download the configured release
if [ ! -f /tmp/xdebug.tgz ]; then
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
    [ "$PHP_VERSION" == "php5" ] && MODULES_DIR="/usr/lib/php5/20121212/"
    [ "$PHP_VERSION" == "php7.0" ] && MODULES_DIR="/usr/lib/php/20151012/"
    cp -f modules/xdebug.so $MODULES_DIR
 
    [ "$PHP_VERSION" == "php5" ] && PHP_DIR="/etc/php5/"
    [ "$PHP_VERSION" == "php7.0" ] && PHP_DIR="/etc/php/7.0/"
 
    # Configure PHP to load xdebug.so
    for i in fpm cli; do
        EXTENSION_CONFIG="zend_extension = ${MODULES_DIR}xdebug.so"
    touch ${PHP_DIR}${i}/conf.d/10-xdebug.ini
        grep -q "$EXTENSION_CONFIG" ${PHP_DIR}${i}/conf.d/10-xdebug.ini || \
            echo -n "$EXTENSION_CONFIG" > ${PHP_DIR}${i}/conf.d/10-xdebug.ini
    done
 
    # Restart PHP and Nginx
    [ "$PHP_VERSION" == "php5" ] && service php5-fpm restart
    [ "$PHP_VERSION" == "php7.0" ] && service php7.0-fpm restart
    service nginx restart
 
fi