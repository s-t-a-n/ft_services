#!/bin/sh
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
