#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/tmp_cert-manager.yaml

exit $?
