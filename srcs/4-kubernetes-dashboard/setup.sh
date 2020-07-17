#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/tmp_kubernetes-dashboard.yaml
kubectl apply -f $basedir/tmp_cluster-admin.yaml
kubectl apply -f $basedir/tmp_cluster-role-binding.yaml
