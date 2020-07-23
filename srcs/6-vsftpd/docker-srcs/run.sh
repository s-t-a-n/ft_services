#!/bin/bash

VSFTPD_USERLIST="/etc/vsftpd.userlist"

IP=
while [[ ! $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; do
	IP=$(/usr/sbin/get_ip.sh)
	sleep 2
done

sed -i s/__ADDRESS__/${IP}/g /etc/vsftpd/vsftpd.conf

if [ ! -d /data/__CLUSTER_ADMIN__ ]; then
	mkdir -p /data/__CLUSTER_ADMIN__ || exit 1
	chown __CLUSTER_ADMIN__:__CLUSTER_ADMIN__ /data/__CLUSTER_ADMIN__ || exit 1
fi

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

exit $?
