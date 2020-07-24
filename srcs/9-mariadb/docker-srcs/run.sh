#!/bin/sh
if [ ! -d /var/lib/mariadb/dashboards ]; then
	mkdir -p /var/lib/mariadb/dashboards /var/lib/mariadb/data /var/lib/mariadb/logs /var/lib/mariadb/plugins
fi

# source : https://github.com/container-examples/alpine-mariadb/blob/master/scripts/start.sh
if [ ! -z ${GF_INSTALL_PLUGINS} ]; then
  OLDIFS=$IFS
  IFS=','
  for plugin in ${GF_INSTALL_PLUGINS}; do
    mariadb-cli plugins install ${plugin}
  done
  IFS=$OLDIFS
fi

chown -R mariadb:mariadb /var/lib/mariadb

rm -f /etc/motd

supervisord -c /etc/supervisord/supervisord.conf

exit $?
