#!/bin/bash

source /auth/*.txt

if ! grep $CLUSTER_ADMIN /etc/passwd 2>/dev/null 1>&2; then
	adduser $CLUSTER_ADMIN --disabled-password || exit 1
	echo "$CLUSTER_ADMIN:$CLUSTER_ADMIN_PW" | chpasswd || exit 1
fi

if ! -d /home/$CLUSTER_ADMIN; then
	mkdir -p /home/$CLUSTER_ADMIN/.ssh || exit  1
	chmod 700 /home/$CLUSTER_ADMIN/.ssh/ || exit 1
	echo "$CLUSTER_ADMIN_SSHPUB" > /home/$CLUSTER_ADMIN/.ssh/authorized_keys || exit 1
	chmod 500 /home/$CLUSTER_ADMIN/.ssh/authorized_keys || exit 1
	chown -R $CLUSTER_ADMIN:$CLUSTER_ADMIN /home/$CLUSTER_ADMIN/ || exit 1
fi

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

exit $?
