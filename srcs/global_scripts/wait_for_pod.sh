#!/bin/sh

function wait_for_pod()
{
	if [ ! $# -eq 2 ]; then
		logp fatal "wait_for_pod expects queue_file and host as parameters!"
	fi
	PODNAME="$1"
	NAMESPACE="$2"
	if [[ $(kubectl get pods -n "$NAMESPACE" $(kubectl get pods -n "$NAMESPACE" | grep "$PODNAME" | awk  '{print $1}')  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; then
		logp info "Waiting for pod "$PODNAME".."
		while [[ $(kubectl get pods -n "$NAMESPACE" $(kubectl get pods -n "$NAMESPACE" | grep "$PODNAME" | awk  '{print $1}')  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
			sleep 1;
			if [ $? -gt 128 ]; then break; fi;
		done
		sleep 2;
	fi
}
