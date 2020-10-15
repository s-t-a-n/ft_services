#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/mysql_inject_database.sh
source $basedir/../cluster-authentication.txt
source $basedir/../cluster-properties.txt

wait_for_pod influxdb default
DB_POD="$(kubectl get pod --all-namespaces| grep influxdb | awk '{print $2}')"
inject_influxdb __SQL_QUEUE_FILE__ "$DB_POD"

exit $?
