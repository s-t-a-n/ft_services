#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

# source : https://medium.com/@stverschuuren/in-loops-which-sleep-if-a-condition-is-not-met-dont-forget-to-add-if-aeff65c6dcc4
if [[ $(kubectl get pods -n cert-manager -l app=cert-manager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; then
	logp info "Waiting for cert-manager.."
	while [[ $(kubectl get pods -n cert-manager -l app=cert-manager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
		sleep 1;
		if [ $? -gt 128 ]; then break; fi;
	done
	sleep 2 # wait for cert-manager to fully boot
fi

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/	\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/	\
&& kubectl apply -f $basedir/tmp_cert.yaml                          \
&& docker build -f tmp_Dockerfile -t vsftpd-alpine:v1 $basedir		\
&& kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml

exit $?
