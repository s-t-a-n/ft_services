#!/bin/sh
basedir=$(dirname "$0")
eval $(minikube docker-env)

kubectl apply -f $basedir/tmp_persistent-volume.yaml
kubectl apply -f $basedir/tmp_persistent-volume-claim.yaml
kubectl apply -f $basedir/tmp_build-env-configjmap.yaml
docker build -t vsftpd-alpine:v1 $basedir
kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml
