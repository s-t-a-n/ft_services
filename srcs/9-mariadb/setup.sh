#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

export MD_DB_TABLE="$MD_DB_TABLE wordpress"
export MD_USER_TABLE="$MD_USER_TABLE WP_USER"
export MD_PW_TABLE="$MD_PW_TABLE WP_PASSWORD"

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/			\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/			\
&& sh $basedir/insert_dynamics.sh											\
&& kubectl apply -k $basedir												\
&& docker build -f $basedir/Dockerfile -t mariadb-alpine:v1 $basedir		\
&& kubectl apply -f $basedir/alpine-mariadb.yaml

exit $?
