#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/tmp_kilo-kubeadm.yaml
