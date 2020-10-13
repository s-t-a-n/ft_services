#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/nginx_inject_site.sh
source $basedir/../cluster-authentication.txt
source $basedir/../cluster-properties.txt

wait_for_pod nginx default

POD="$(kubectl get pod --all-namespaces| grep nginx | awk '{print $2}')"
[ "$POD" = "" ] && logp warning "Couldn't find nginx pod!" && exit 1
inject_site __NGINX_QUEUE_FILE__ "$POD"

exit $?
