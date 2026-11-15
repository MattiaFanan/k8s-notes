#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/storageclass.yaml -f $D/pvc.yaml -f $D/deployment.yaml
kubectl rollout status -n storage-02 deploy/web --timeout=120s
kubectl exec -n storage-02 deploy/web -- sh -c 'echo "hello from pv" > /usr/share/nginx/html/index.html'
