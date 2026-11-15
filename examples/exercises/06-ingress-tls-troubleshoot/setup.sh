#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns ingress-06
# Service selector deliberately wrong (app=shop)
echo_app ingress-06 store 80 shop
kubectl apply -f - <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: store
  namespace: ingress-06
spec:
  ingressClassName: traefik
  rules:
  - host: store.ckad.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: store-svc
            port: {number: 8080}
YAML
kubectl wait -n ingress-06 --for=condition=Available deploy/store --timeout=120s
