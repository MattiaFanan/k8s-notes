#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/rbac.yaml -f $D/rolebinding.yaml
kubectl replace --force --grace-period=0 -f $D/pod.yaml
kubectl wait -n rbac-12 pod/ci-runner --for=condition=Ready --timeout=120s
