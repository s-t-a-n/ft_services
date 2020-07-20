#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/tmp_haproxy.yaml						\
&& kubectl apply -f $basedir/tmp_cluster-role-binding.yaml		\
&& kubectl apply -f $basedir/tmp_default-backend.yaml			\
&& kubectl apply -f $basedir/tmp_haproxy-configmap.yaml			\
&& kubectl apply -f $basedir/tmp_haproxy-ingress.yaml

exit $?
