#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
mkdir -p "$(dirname "$0")/work"
ns probe-21
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: shop, namespace: probe-21}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop}}
  template:
    metadata: {labels: {app: shop}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        readinessProbe:
          tcpSocket: {port: 8080}
          periodSeconds: 5
        livenessProbe:
          httpGet: {path: /healthz, port: 80}
          periodSeconds: 5
          failureThreshold: 1
---
apiVersion: v1
kind: Pod
metadata: {name: crasher, namespace: probe-21}
spec:
  containers:
  - name: c
    image: busybox:1.36
    command: ["sh", "-c", "echo starting; sleep 15; echo 'FATAL: config file /etc/app/app.conf not found' >&2; exit 1"]
---
apiVersion: v1
kind: Pod
metadata: {name: app, namespace: probe-21}
spec:
  containers:
  - name: app
    image: registry.k8s.io/pause:3.10
YAML
