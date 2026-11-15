#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
helm uninstall ingress-nginx -n ingress-nginx --wait 2>/dev/null
kubectl delete ns helm-14 ingress-nginx --ignore-not-found
