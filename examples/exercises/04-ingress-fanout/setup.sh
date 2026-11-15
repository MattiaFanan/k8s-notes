#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns ingress-04
echo_app ingress-04 web 8080
echo_app ingress-04 api 9090
kubectl rollout status -n ingress-04 deploy/web deploy/api --timeout=120s 2>/dev/null || kubectl wait -n ingress-04 --for=condition=Available deploy --all --timeout=120s
