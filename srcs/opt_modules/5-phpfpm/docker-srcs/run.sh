#!/bin/bash

source /config/* #|| exit 1

SUFFIX=$(echo $PHPFPM_VERSION | cut -f1 -d\.)
mkdir -p /run/php-fpm$SUFFIX && mkdir -p /var/log/php$SUFFIX #|| exit 1

rm -f /etc/motd
supervisord -c /etc/supervisord/supervisord.conf

tail -f /dev/null # remove when ready

exit $?
