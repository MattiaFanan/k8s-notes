#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl apply -f "$(dirname "$0")"/pv.yaml -f "$(dirname "$0")"/pvc.yaml -f "$(dirname "$0")"/pod.yaml
kubectl wait -n storage-01 pod/logger --for=condition=Ready --timeout=120s
