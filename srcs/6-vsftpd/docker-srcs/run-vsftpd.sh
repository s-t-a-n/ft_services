#!/bin/sh

VSFTPD_USERLIST="/etc/vsftpd.userlist"

source /auth/*.txt

# API_URL=https://kubernetes
# TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
# POD_NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
# export HOST_IP=$(curl -s $API_URL/api/v1/namespaces/$POD_NAMESPACE/pods/$HOSTNAME --header "Authorization: Bearer $TOKEN" --insecure | jq -r '.status.hostIP')

sed -i s/__ADDRESS__/${HOSTNAME}/g /etc/vsftpd/vsftpd.conf

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

/sbin/syslogd &

 /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
 