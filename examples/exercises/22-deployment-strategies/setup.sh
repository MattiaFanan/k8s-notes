#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns deploy-22
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: {name: blue, namespace: deploy-22}
spec:
  replicas: 2
  selector: {matchLabels: {app: shop, version: blue}}
  template:
    metadata: {labels: {app: shop, version: blue}}
    spec:
      containers: [{name: echo, image: "hashicorp/http-echo:1.0", args: ["-text=v1", "-listen=:5678"]}]
---
apiVersion: v1
kind: Service
metadata: {name: shop, namespace: deploy-22}
spec:
  selector: {app: shop, version: blue}
  ports: [{port: 80, targetPort: 5678}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: catalog, namespace: deploy-22}
spec:
  replicas: 4
  selector: {matchLabels: {app: catalog, track: stable}}
  template:
    metadata: {labels: {app: catalog, track: stable}}
    spec:
      containers: [{name: echo, image: "hashicorp/http-echo:1.0", args: ["-text=catalog-v1", "-listen=:5678"]}]
---
apiVersion: v1
kind: Service
metadata: {name: catalog, namespace: deploy-22}
spec:
  selector: {app: catalog}
  ports: [{port: 80, targetPort: 5678}]
YAML
kubectl wait -n deploy-22 --for=condition=Available deploy --all --timeout=120s
