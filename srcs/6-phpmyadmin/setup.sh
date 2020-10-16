#!/bin/sh
basedir=$(dirname "$0")
source $basedir/../global_scripts/logp.sh
source $basedir/../global_scripts/wait_for_pod.sh
source $basedir/../global_scripts/mysql_queue_database_injection.sh
source $basedir/config.txt
eval $(minikube docker-env)

trap "rm -rf $basedir/docker-srcs/global_container_scripts && rm -rf $basedir/docker-srcs/global_container_confs" EXIT INT

cp -r $basedir/../global_container_scripts $basedir/docker-srcs/			\
&& cp -r $basedir/../global_container_confs $basedir/docker-srcs/			\
&& kubectl apply -k $basedir												\
&& docker build --build-arg PHP_VERSION="$PHP_VERSION" 						\
				--build-arg PHPFPM_VERSION="$PHPFPM_VERSION"				\
				--build-arg PHP_MODULES="$PHP_MODULES"						\
				-f $basedir/Dockerfile										\
				-t phpmyadmin-alpine:v1 $basedir								\
&& kubectl apply -f $basedir/alpine-phpmyadmin.yaml							\
&& queue_database_injection "$PHPMYADMIN_DB_NAME" "$PHPMYADMIN_DB_USER" "$PHPMYADMIN_DB_PW" "__SQL_QUEUE_FILE__"
