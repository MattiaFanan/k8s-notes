#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns ingress-05
echo_app ingress-05 hello 80
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: legacy
  namespace: ingress-05
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: legacy.ckad.local
    http:
      paths:
      - {path: /, pathType: Prefix, backend: {service: {name: hello, port: {number: 80}}}}
YAML
kubectl wait -n ingress-05 --for=condition=Available deploy/hello --timeout=120s
