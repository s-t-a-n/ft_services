#!/bin/sh
source /config/* || exit 1

PHP_FPM=$(which php-fpm$(echo $PHPFPM_VERSION | cut -f1 -d\.))

$PHP_FPM -F $@
