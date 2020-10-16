#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/insert_variables.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/influxdb_queue_database_injection.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

if ! kubectl get serviceaccounts monitoring &>/dev/null ; then
	kubectl create serviceaccount monitoring || logp fatal "Couldn't add serviceaccount for telegraf inventory gathering.."
fi

source $basedir/telegraf-secrets.txt																			\
&& cp -r $basedir/../global_container_scripts $basedir/docker-srcs/												\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/												\
&& kubectl apply -k $basedir																					\
&& kubectl apply -f $basedir/monitoring-role-binding.yaml														\
&& docker build -f $basedir/Dockerfile -t telegraf-alpine:v1 $basedir											\
&& kubectl apply -f $basedir/alpine-telegraf.yaml																\
&& queue_influxdb_injection "$TELEGRAF_INFLUX_DB_NAME" "__INFLUXDB_QUEUE_FILE__"
