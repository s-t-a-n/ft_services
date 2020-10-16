#!/bin/sh
basedir=$(dirname "$0")
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/			\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/			\
&& docker build -f $basedir/Dockerfile -t influxdb-alpine:v1 $basedir	\
&& kubectl apply -f $basedir/alpine-influxdb.yaml
