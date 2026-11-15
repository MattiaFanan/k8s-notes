#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(cd "$(dirname "$0")" && pwd); W="$D/../../exercises/16-kustomize-overlays/work"
mkdir -p "$W"; cp -r "$D/base" "$D/overlays" "$W/"
kubectl apply -k "$W/overlays/dev"
kubectl apply -k "$W/overlays/prod"
kubectl rollout status -n kust-dev deploy/dev-web --timeout=120s
kubectl rollout status -n kust-prod deploy/prod-web --timeout=180s
