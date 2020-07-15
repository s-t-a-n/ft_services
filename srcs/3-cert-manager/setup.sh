#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/cert-manager.yaml

