#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/kubernetes-dashboard.yaml
kubectl apply -f $basedir/cluster-admin.yaml
kubectl apply -f $basedir/cluster-role-binding.yaml
kubectl expose deployment kubernetes-dashboard --name kubernetes-dashboard-exposed -n kubernetes-dashboard --type=LoadBalancer --port=8443 --target-port=8443
