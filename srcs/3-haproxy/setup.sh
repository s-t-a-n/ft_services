#!/bin/sh
basedir=$(dirname "$0")

kubectl apply -f $basedir/haproxy.yaml
kubectl apply -f $basedir/cluster-role-binding.yaml
kubectl apply -f $basedir/default-backend.yaml
kubectl apply -f $basedir/haproxy-configmap.yaml
kubectl apply -f $basedir/haproxy-ingress.yaml
