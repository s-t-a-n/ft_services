#!/bin/sh

kubectl apply -f https://k8s.io/examples/application/deployment.yaml
kubectl expose deployment nginx-deployment --type=LoadBalancer --port=80

sleep  5
kubectl get all
