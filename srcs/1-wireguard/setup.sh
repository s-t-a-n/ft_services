#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/wireguard.yaml

for node in $(kubectl get nodes | grep -i gcp | awk '{print $1}'); do kubectl annotate node $node kilo.squat.ai/location="gcp"; done
