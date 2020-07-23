#!/bin/sh
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

if [ ! -d /var/lib/grafana/dashboards ]; then
	mkdir -p /var/lib/grafana/dashboards /var/lib/grafana/data /var/lib/grafana/logs /var/lib/grafana/plugins
fi

# source : https://github.com/container-examples/alpine-grafana/blob/master/scripts/start.sh
if [ ! -z ${GF_INSTALL_PLUGINS} ]; then
  OLDIFS=$IFS
  IFS=','
  for plugin in ${GF_INSTALL_PLUGINS}; do
    grafana-cli plugins install ${plugin}
  done
  IFS=$OLDIFS
fi

chown -R grafana:grafana /var/lib/grafana

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

tail -f /dev/null

exit $?
