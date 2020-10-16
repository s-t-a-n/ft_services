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
				--build-arg WP_ADMIN="$WP_ADMIN"							\
				--build-arg WP_ADMIN_PW="$WP_ADMIN_PW"						\
				--build-arg WP_ADMIN_MAIL="$WP_ADMIN_MAIL"					\
				--build-arg WP_DB_NAME="$WP_DB_NAME"						\
				--build-arg WP_DB_USER="$WP_DB_USER"						\
				--build-arg WP_DB_PW="$WP_DB_PW"							\
				-f $basedir/Dockerfile										\
				-t wordpress-alpine:v1 $basedir								\
&& kubectl apply -f $basedir/alpine-wordpress.yaml							\
&& queue_database_injection "$WP_DB_NAME" "$WP_DB_USER" "$WP_DB_PW" "__SQL_QUEUE_FILE__"
