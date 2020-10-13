#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/mysql_queue_database_injection.sh
source $basedir/../global_scripts/nginx_queue_site_injection.sh
eval $(minikube docker-env)

source $basedir/config.txt \
&& queue_database_injection "$WORDPRESS_DB_NAME" "$WORDPRESS_DB_USER" "$WORDPRESS_DB_PW" "__SQL_QUEUE_FILE__" \
&& queue_site_injection "$WORDPRESS_NGINX_CONF" "!!!DIR" __NGINX_QUEUE_FILE__ \
|| logp fatal "Failed to queue database/site injection!"

exit $?
