#!/bin/sh
basedir=$(dirname "$0")
source $basedir/srcs/global_scripts/logp.sh
source $basedir/srcs/global_scripts/mysql_inject_database.sh
source $basedir/srcs/cluster-authentication.txt

DB_POD="$(kubectl get pod --all-namespaces| grep mariadb | awk '{print $2}')"

#echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '__MYSQL_ROOT_PASSWORD__;\n$(cat $SQL_QUEUE_FILE)" > $SQL_QUEUE_FILE
inject_databases "$SQL_QUEUE_FILE" "$DB_POD"

exit $?
