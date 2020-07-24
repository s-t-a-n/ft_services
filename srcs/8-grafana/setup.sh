#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/insert_variables.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

# source : https://medium.com/@stverschuuren/in-loops-which-sleep-if-a-condition-is-not-met-dont-forget-to-add-if-aeff65c6dcc4
if [[ $(kubectl get pods -n cert-manager $(kubectl get pods -n cert-manager | grep cert-manager-webhook | awk  '{print $1}')  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; then
	logp info "Waiting for cert-manager.."
	while [[ $(kubectl get pods -n cert-manager $(kubectl get pods -n cert-manager | grep cert-manager-webhook | awk  '{print $1}')  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
		sleep 1;
		if [ $? -gt 128 ]; then break; fi;
	done
	sleep 2;
fi

source $basedir/grafana-secrets.txt

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/												\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/												\
&& $basedir/../global_scripts/mysql_update_dynamics.sh "$GRAFANA_DB_NAME" "$GRAFANA_DB_USER" "$GRAFANA_DB_PW"	\
&& kubectl apply -k $basedir																					\
&& kubectl apply -f $basedir/cert.yaml																			\
&& docker build -f $basedir/Dockerfile -t grafana-alpine:v1 $basedir											\
&& kubectl apply -f $basedir/alpine-grafana.yaml
exit $?
