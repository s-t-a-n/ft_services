#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/persistent-volume.yaml
kubectl create -f $basedir/persistent-volume-claim.yaml
kubectl apply -f $basedir/build-env-configmap.yaml
docker build -t vsftpd-alpine:v1 $basedir
kubectl apply -f $basedir/alpine-vsftpd.yaml
