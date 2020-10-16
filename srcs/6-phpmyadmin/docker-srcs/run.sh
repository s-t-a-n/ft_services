#!/bin/bash

source /config/* #|| exit 1

until nc -w1 -z $PHPMYADMIN_DB_HOST 3306 >/dev/null 2>&1; do :; done

# NGINX
mkdir -p /run/nginx && mkdir -p /var/log/nginx && mkdir -p /data/http #|| exit 1

# WORDPRESS
PHPMYADMIN_ROOT=/data/http/phpmyadmin
if [ ! -d $PHPMYADMIN_ROOT ]; then
	mkdir -p $PHPMYADMIN_ROOT && chown -R nginx:nginx $PHPMYADMIN_ROOT #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
	wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
	tar -xzvf phpMyAdmin-5.0.1-english.tar.gz --strip-components=1 -C $PHPMYADMIN_ROOT #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
	cp /config.inc.php $PHPMYADMIN_ROOT/ #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
	chmod 777 $PHPMYADMIN_ROOT/tmp #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
	chown -R nginx:nginx $PHPMYADMIN_ROOT #|| { rm -rf $PHPMYADMIN_ROOT && exit 1 }
fi

# PHP
PHP_SUFFIX=$(echo $PHPFPM_VERSION | cut -f1 -d\.)
mkdir -p /run/php-fpm$PHP_SUFFIX && mkdir -p /var/log/php$PHP_SUFFIX

# UNIVERSAL
rm -f /etc/motd
supervisord -c /etc/supervisord/supervisord.conf

exit $?
