#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/tmp_persistent-volume.yaml
kubectl create -f $basedir/tmp_persistent-volume-claim.yaml
kubectl apply -f $basedir/tmp_build-env-configjmap.yaml
docker build -t vsftpd-alpine:v1 $basedir
kubectl apply -f $basedir/tmp_alpine-vsftpd.yaml
