#!/bin/sh
basedir=$(dirname "$0")
source $basedir/srcs/global_scripts/logp.sh
source $basedir/srcs/global_scripts/wait_for_pod.sh
source $basedir/srcs/global_scripts/nginx_inject_site.sh
source $basedir/srcs/cluster-authentication.txt

wait_for_pod nginx default

POD="$(kubectl get pod --all-namespaces| grep nginx | awk '{print $2}')"
inject_sites "$SQL_QUEUE_FILE" "$POD"

exit $?
