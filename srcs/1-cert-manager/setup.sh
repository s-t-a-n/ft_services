#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/cert-manager.yaml

exit $?
