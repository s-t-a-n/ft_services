#!/bin/bash

VSFTPD_USERLIST="/etc/vsftpd.userlist"

source /auth/*.txt

IP=
while [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
	IP=$(/usr/sbin/get_ip.sh)
	sleep 2
done

sed -i s/__ADDRESS__/${IP}/g /etc/vsftpd/vsftpd.conf

if ! grep $CLUSTER_ADMIN /etc/passwd 2>/dev/null 1>&2; then
	adduser $CLUSTER_ADMIN --disabled-password || exit 1
	echo "$CLUSTER_ADMIN:$CLUSTER_ADMIN_PW" | chpasswd || exit 1
fi

if [ ! -d /data/$CLUSTER_ADMIN ]; then
	mkdir -p /data/$CLUSTER_ADMIN
	chown $CLUSTER_ADMIN:$CLUSTER_ADMIN /data/$CLUSTER_ADMIN
fi

if ! grep $CLUSTER_ADMIN $VSFTPD_USERLIST 2>/dev/null 1>&2; then
	echo $CLUSTER_ADMIN >> $VSFTPD_USERLIST || exit 1
fi

if [ ! -f /etc/ssl/private/vsftpd.pem ]; then
	openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout /etc/ssl/private/vsftpd.pem -subj "/C=NL/ST=Test/L=Test/O=Test/CN=vsftpd" -out /etc/ssl/private/vsftpd.pem || exit 1
fi

/sbin/syslogd & # remove when ready

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf

tail -f /dev/null # remove when ready
 
