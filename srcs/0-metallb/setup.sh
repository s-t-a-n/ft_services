#!/bin/sh

kubectl apply -f namespace.yaml
kubectl apply -f metallb.yaml

# On first install only
if ! kubectl get secrets -n metallb-system memberlist 2>/dev/null 1>&2; then
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
fi

kubectl apply -f config.yaml
