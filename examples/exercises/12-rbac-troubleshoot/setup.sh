#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns rbac-12
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ServiceAccount
metadata: {name: ci-bot, namespace: rbac-12}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: {name: ci-deployer, namespace: rbac-12}
rules:
- apiGroups: [""]
  resources: [deployments]
  verbs: [get, list, create]
- apiGroups: [""]
  resources: [pod]
  verbs: [get, list]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata: {name: ci-deployer, namespace: rbac-12}
roleRef: {apiGroup: rbac.authorization.k8s.io, kind: Role, name: ci-deployer}
subjects:
- {kind: ServiceAccount, name: ci-bot, namespace: default}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: app, namespace: rbac-12}
spec:
  replicas: 1
  selector: {matchLabels: {app: app}}
  template:
    metadata: {labels: {app: app}}
    spec:
      containers: [{name: nginx, image: nginx:1.27-alpine}]
---
apiVersion: v1
kind: Pod
metadata: {name: ci-runner, namespace: rbac-12}
spec:
  containers:
  - {name: runner, image: busybox:1.36, command: [sleep, "3600"]}
YAML
