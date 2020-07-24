#!/bin/sh
basedir=$(dirname "$0")
source $basedir/srcs/global_scripts/logp.sh
source $basedir/srcs/global_scripts/mysql_inject_database.sh
source $basedir/srcs/cluster-authentication.txt

DB_POD="$(kubectl get pod --all-namespaces| grep mariadb | awk '{print $2}')"

inject_databases "$SQL_QUEUE_FILE" "root" "$MYSQL_ROOT_PASSWORD" "$DB_POD"

exit $?
