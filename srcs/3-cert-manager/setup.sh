#!/bin/sh
basedir=$(dirname "$0")

kubectl create -f $basedir/tmp_cert-manager.yaml
