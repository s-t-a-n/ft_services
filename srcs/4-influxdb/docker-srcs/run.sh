#!/bin/sh

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

exit $?
