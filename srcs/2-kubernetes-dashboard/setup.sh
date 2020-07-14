#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/kubernetes-dashboard.yaml
kubectl apply -f $basedir/cluster-admin.yaml
kubectl apply -f $basedir/cluster-role-binding.yaml
