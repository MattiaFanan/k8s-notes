#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl delete pod db -n storage-03 --ignore-not-found --grace-period=0 --force
kubectl delete pvc pvc-db -n storage-03 --ignore-not-found
kubectl apply -f $D/pvc.yaml -f $D/pod.yaml
kubectl wait -n storage-03 pod/db --for=condition=Ready --timeout=120s
