#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
# second traefik, Gateway API only. --skip-crds: the CRDs already come with k3s. shortcut: --repo instead of 'helm repo add'
helm upgrade --install traefik-gw traefik --repo https://traefik.github.io/charts --version 42.3.2 \
  -n gateway-system --create-namespace --skip-crds --wait --timeout 5m -f - <<'YAML'
providers:
  kubernetesCRD: {enabled: false}
  kubernetesIngress: {enabled: false}
  kubernetesGateway: {enabled: true}
ingressClass: {enabled: false}
gateway: {enabled: false}
gatewayClass: {enabled: false}
service:
  spec: {type: NodePort}
ports:
  web: {nodePort: 30180}
  websecure: {expose: {default: false}}
YAML
ns gw-29; ns gw-29-blocked
for a in store-v1 store-v2 admin; do echo_app gw-29 $a 80; done
echo_app gw-29-blocked sneaky 80
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: sneaky, namespace: gw-29-blocked}
spec:
  parentRefs: [{name: web-gw, namespace: gateway-system}]
  hostnames: [sneaky.ckad.local]
  rules:
  - backendRefs: [{name: sneaky, port: 80}]
YAML
kubectl wait -n gw-29 --for=condition=Available deploy --all --timeout=120s
