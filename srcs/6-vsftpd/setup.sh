#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/persistent-volume.yaml
kubectl create -f $basedir/persistent-volume-claim.yaml
docker build -t vsftpd-alpine:v1 $basedir
# persistent volume claim
# deployment
