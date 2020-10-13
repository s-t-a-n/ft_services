#!/bin/bash

mkdir -p /run/nginx && mkdir -p /var/log/nginx && mkdir -p /data/http #|| exit 1

# uncomment to load a custom default.conf
#if [ ! -d /data/http/default ] ||  [ ! -f /data/http/default/index.html ]; then
#	mkdir -p /data/http/default	\
#		&& echo "Hello World" > /data/http/default/index.html \
#		&& chown -R nginx:nginx /data/http #|| exit 1
#fi

# just for ft_services
if [ ! -f /data/http/default/index.html ]; then
	mkdir -p /data/http/default
	mv /index.html /data/http/default
	chown -R nginx:nginx /data/http
fi

if [ -d /data/nginx-conf ] && [ ! -L /etc/nginx ]; then 
	echo "Nginx configuration already exists in /data/nginx..."
	BACKUPD="/data/nginx-$(date +%D)"
	echo "Moving existing configuration to $BACKUPD"
	mv /data/nginx-conf $BACKUPD #|| exit 1
fi

if [ ! -L /etc/nginx ]; then
	mv /etc/nginx /data/nginx-conf && ln -s /data/nginx-conf /etc/nginx
fi

if [ ! -L /data/nginx-conf/sites-enabled/default ]; then
	(cd /data/nginx-conf/sites-enabled/ && ln -s ../sites-available/default.conf ./) #|| exit 1
fi

rm -f /etc/motd
supervisord -c /etc/supervisord/supervisord.conf

tail -f /dev/null # remove when ready

exit $?
