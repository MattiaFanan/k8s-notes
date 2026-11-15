#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/rbac.yaml -f $D/pod.yaml
kubectl wait -n sa-08 pod/api-client --for=condition=Ready --timeout=120s && sleep 3
