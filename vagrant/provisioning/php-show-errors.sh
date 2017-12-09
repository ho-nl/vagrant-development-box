which php5 && PHP_VERSION="php5" || /bin/true
which php7.0 && PHP_VERSION="php7.0" || /bin/true

[ "$PHP_VERSION" == "php5" ] && MODULES_DIR="/usr/lib/php5/20121212/"
[ "$PHP_VERSION" == "php7.0" ] && MODULES_DIR="/usr/lib/php/20151012/"

[ "$PHP_VERSION" == "php5" ] && PHP_DIR="/etc/php5/"
[ "$PHP_VERSION" == "php7.0" ] && PHP_DIR="/etc/php/7.0/"

for i in fpm cli; do
    CONFIG="display_errors = On
display_startup_errors = On
";

    rm -f ${PHP_DIR}${i}/conf.d/30-show-errors.ini;
    touch ${PHP_DIR}${i}/conf.d/30-show-errors.ini
    echo -n "${CONFIG}" > ${PHP_DIR}${i}/conf.d/30-show-errors.ini
done

# Restart PHP and Nginx
[ "$PHP_VERSION" == "php5" ] && service php5-fpm restart
[ "$PHP_VERSION" == "php7.0" ] && service php7.0-fpm restart
service nginx restart
