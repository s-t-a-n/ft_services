#!/bin/bash

mkdir -p /run/nginx && mkdir -p /var/log/nginx || exit 1

if [ -d /data/nginx-conf ] && [ ! -L /etc/nginx ]; then 
	echo "Nginx configuration already exists in /data/nginx..."
	BACKUPD="/data/nginx-$(date +%D)"
	echo "Moving existing configuration to $BACKUPD"
	mv /data/nginx-conf $BACKUPD #|| exit 1
fi
if [ ! -L /etc/nginx ]; then
	mv /etc/nginx /data/nginx-conf && ln -s /data/nginx-conf /etc/nginx
fi

rm -f /etc/motd
supervisord -c /etc/supervisord/supervisord.conf

tail -f /dev/null # remove when ready

exit $?
