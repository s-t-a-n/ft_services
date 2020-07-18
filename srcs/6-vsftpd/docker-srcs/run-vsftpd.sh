#!/bin/sh

VSFTPD_USERLIST="/etc/vsftpd.userlist"

sleep 100

source /auth/*.txt

if ! grep $CLUSTER_ADMIN /etc/passwd 2>/dev/null 1>&2; then
	adduser $CLUSTER_ADMIN --disabled-password || exit 1
	echo "$CLUSTER_ADMIN:$CLUSTER_ADMIN_PW" | sudo chpasswd || exit 1
fi

if ! grep $CLUSTER_ADMIN $VSFTPD_USERLIST 2>/dev/null 1>&2; then
	echo $CLUSTER_ADMIN >> $VSFTPD_USERLIST || exit 1
fi

if [ ! -f /etc/ssl/private/vsftpd.pem ]; then
	openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.
pem -out /etc/ssl/private/vsftpd.pem || exit 1
fi

vsftpd
