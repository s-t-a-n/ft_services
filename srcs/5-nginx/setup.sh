#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

wait_for_pod cert-manager-webhook cert-manager

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/			\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/			\
&& kubectl apply -f $basedir/cert.yaml										\
&& docker build -f $basedir/Dockerfile -t nginx-alpine:v1 $basedir			\
&& kubectl apply -f $basedir/alpine-nginx.yaml

exit $?
