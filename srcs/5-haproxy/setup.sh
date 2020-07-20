#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/tmp_haproxy-ingress.yaml				\
&& kubectl apply -f $basedir/tmp_cluster-role-binding.yaml		\
&& kubectl apply -f $basedir/tmp_default-backend.yaml			\
&& kubectl apply -f $basedir/tmp_haproxy-configmap.yaml			\

exit $?
