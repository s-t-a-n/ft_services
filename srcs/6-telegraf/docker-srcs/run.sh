#!/bin/sh

until nc -w1 -z influxdb 8086 >/dev/null 2>&1; do :; done

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

exit $?
