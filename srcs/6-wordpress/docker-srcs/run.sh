#!/bin/bash

source /config/* #|| exit 1

# NGINX
mkdir -p /run/nginx && mkdir -p /var/log/nginx && mkdir -p /data/http #|| exit 1

# WORDPRESS
WP_ROOT=/data/http/wordpress
if [ ! -d $WP_ROOT ]; then
	mkdir -p $WP_ROOT && chown -R nginx:nginx $WP_ROOT
	su-exec nginx wp core download --path=$WP_ROOT #|| { rm -rf $WP_ROOT && exit 1 }
	su-exec nginx wp config create --path=$WP_ROOT --dbname="$WP_DB_NAME" --dbuser="$WP_DB_USER" --dbpass="$WP_DB_PW" --dbhost="$WP_DB_HOST" #|| { rm -rf $WP_ROOT && exit 1 }
	su-exec nginx wp core install --path=$WP_ROOT --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PW" --admin_email="$WP_ADMIN_MAIL" --skip-email #|| { rm -rf $WP_ROOT && exit 1 }
fi

# PHP
PHP_SUFFIX=$(echo $PHPFPM_VERSION | cut -f1 -d\.)
mkdir -p /run/php-fpm$PHP_SUFFIX && mkdir -p /var/log/php$PHP_SUFFIX #|| exit 1

# UNIVERSAL
rm -f /etc/motd
supervisord -c /etc/supervisord/supervisord.conf

tail -f /dev/null # remove when ready

exit $?
