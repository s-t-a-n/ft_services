#!/bin/sh
basedir=$(dirname "$0")
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

# source : https://medium.com/@stverschuuren/in-loops-which-sleep-if-a-condition-is-not-met-dont-forget-to-add-if-aeff65c6dcc4
while [[ $(kubectl get pods -n cert-manager -l app=cert-manager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
	echo "Waiting for cert-manager.." && sleep 1;
	if [ $? -gt 128 ]; then break; fi;
done

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/	\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/	\
&& kubectl apply -f $basedir/tmp_cert.yaml                          \
&& docker build -t vsftpd-alpine:v1 $basedir						\
&& kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml

exit $?
