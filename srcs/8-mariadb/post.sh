#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/mysql_inject_database.sh
source $basedir/../cluster-authentication.txt
source $basedir/../cluster-properties.txt

wait_for_pod mariadb default
DB_POD="$(kubectl get pod --all-namespaces| grep mariadb | awk '{print $2}')"
#echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '__MYSQL_ROOT_PASSWORD__;\n$(cat $SQL_QUEUE_FILE)" > $SQL_QUEUE_FILE
inject_databases __SQL_QUEUE_FILE__ "$DB_POD"

exit $?
