#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns gw-29 gw-29-blocked --ignore-not-found
kubectl delete gateway --all -n gateway-system --ignore-not-found --timeout=30s
kubectl delete gatewayclass ckad-gw --ignore-not-found --timeout=30s || \
  kubectl patch gatewayclass ckad-gw --type merge -p '{"metadata":{"finalizers":null}}'
helm uninstall traefik-gw -n gateway-system --wait 2>/dev/null
kubectl delete ns gateway-system --ignore-not-found
