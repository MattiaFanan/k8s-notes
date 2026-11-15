#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/sa.yaml -f $D/pods.yaml
kubectl wait -n sa-07 pod --all --for=condition=Ready --timeout=120s
kubectl create token builder -n sa-07 --duration=10m >/dev/null
