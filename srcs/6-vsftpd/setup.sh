#!/bin/sh
basedir=$(dirname "$0")
eval $(minikube docker-env)

kubectl apply -f $basedir/tmp_build-env-configmap.yaml      \
&& docker build -t vsftpd-alpine:v1 $basedir                \
&& kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml

exit $?
