#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/sed_i.sh
source $basedir/../global_scripts/insert_variables.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/mysql_queue_database_injection.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

wait_for_pod cert-manager-webhook cert-manager

source $basedir/grafana-secrets.txt																				\
&& sed_i "s|__GRAFANA_DB_NAME__|$GRAFANA_DB_NAME|g" $basedir/docker-srcs/grafana.ini							\
&& sed_i "s|__GRAFANA_DB_USER__|$GRAFANA_DB_USER|g" $basedir/docker-srcs/grafana.ini							\
&& sed_i "s|__GRAFANA_DB_PW__|$GRAFANA_DB_PW|g" $basedir/docker-srcs/grafana.ini								\
&& queue_database_injection "$GRAFANA_DB_NAME" "$GRAFANA_DB_USER" "$GRAFANA_DB_PW" "__SQL_QUEUE_FILE__"			\
&& cp -r $basedir/../global_container_scripts $basedir/docker-srcs/												\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/												\
&& kubectl apply -k $basedir																					\
&& kubectl apply -f $basedir/cert.yaml																			\
&& docker build -f $basedir/Dockerfile -t grafana-alpine:v1 $basedir											\
&& kubectl apply -f $basedir/alpine-grafana.yaml
exit $?
