#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/config
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/			\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/			\
&& docker build --build-arg PHP_VERSION=$PHP_VERSION 						\
				--build-arg PHPFPM_VERSION=$PHPFPM_VERSION					\
				-f $basedir/Dockerfile										\
				-t phpfpm-alpine:v1 $basedir								\
&& kubectl apply -f $basedir/alpine-phpfpm.yaml
exit $?