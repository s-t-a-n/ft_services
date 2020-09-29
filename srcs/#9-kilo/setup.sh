#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/kilo-kubeadm.yaml

exit $?
