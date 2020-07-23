#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/wireguard.yaml

exit $?
