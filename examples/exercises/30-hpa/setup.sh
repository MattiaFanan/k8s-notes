#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns hpa-30
kubectl create deploy api -n hpa-30 --image=registry.k8s.io/hpa-example --replicas=2 --port=80 --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl expose deploy api -n hpa-30 --port=80 --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl rollout status deploy/api -n hpa-30 --timeout=180s
