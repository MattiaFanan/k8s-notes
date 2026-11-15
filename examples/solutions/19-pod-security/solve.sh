#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl label ns psa-19 pod-security.kubernetes.io/enforce=restricted pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/warn=restricted --overwrite
kubectl apply -f "$(dirname "$0")"/pods.yaml
kubectl wait -n psa-19 pod --all --for=condition=Ready --timeout=120s
