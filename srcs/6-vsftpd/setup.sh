#!/bin/sh
basedir=$(dirname "$0")
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

while [ ! "$(kubectl get pods --all-namespaces | grep cert-manager | grep Running | wc -l | xargs)" = "3" ]; do
    sleep 1
done

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/	\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/	\
&& kubectl apply -f $basedir/tmp_build-env-configmap.yaml			\
&& kubectl apply -f $basedir/tmp_cert.yaml                          \
&& docker build -t vsftpd-alpine:v1 $basedir						\
&& kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml

exit $?
