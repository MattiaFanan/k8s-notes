#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
mkdir -p "$(dirname "$0")/work"
for n in dev-32 storage-32 batch-32; do ns $n; done
kubectl apply -f - >/dev/null <<'YAML'
apiVersion: v1
kind: ResourceQuota
metadata: {name: compute, namespace: dev-32}
spec:
  hard: {requests.cpu: 500m, limits.cpu: 600m}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: dev-32}
spec:
  replicas: 2
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        resources: {requests: {cpu: 100m}}
YAML
echo "namespaces dev-32, storage-32, batch-32 ready"
