PHP_V=$(php -v|awk '{ print $0 }'|awk -F\, '{ print $1 }')
PHP_VERSION=${PHP_V:4:3}

echo "🔥  Ensuring php errors are shown in the browser"

for i in fpm cli; do
    CONFIG="display_errors = On
display_startup_errors = On
";

    rm -f /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini;
    touch /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini
    echo -n "${CONFIG}" > /etc/php/${PHP_VERSION}/${i}/conf.d/30-show-errors.ini
done

# Restart PHP
sudo service "php${PHP_VERSION}-fpm" stop
