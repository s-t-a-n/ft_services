#!/bin/sh
basedir=$(dirname "$0")

kubectl expose deployment kubernetes-dashboard --name kubernetes-dashboard-exposed -n kubernetes-dashboard --type=LoadBalancer --port=8443 --target-port=8443
