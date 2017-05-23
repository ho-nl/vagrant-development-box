#!/bin/bash

cd $HOME
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xf ioncube_loaders_lin_x86-64.tar.gz
rm ioncube_loaders_lin_x86-64.tar.gz

PHP_EXTENSION_DIR=`echo "<?php echo ini_get('extension_dir'); ?>" | php`/
PHP_VERSION=`echo "<?php echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION ?>" | php`

sudo cp $HOME/ioncube/ioncube_loader_lin_$PHP_VERSION.so $PHP_EXTENSION_DIR
echo "zend_extension=ioncube_loader_lin_$PHP_VERSION.so" > 00-ioncube.ini
sudo mv 00-ioncube.ini /etc/php/$PHP_VERSION/fpm/conf.d/

rm -rf $HOME/ioncube
sudo service php$PHP_VERSION-fpm restart