#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(cd "$(dirname "$0")" && pwd); W="$D/../../exercises/17-kustomize-generators-patches/work"
cp "$D/kustomization.yaml" "$D/patch-resources.yaml" "$W/"
kubectl apply -k "$W" && kubectl rollout status -n kust-17 deploy/api --timeout=120s
sed -i 's/LOG_LEVEL=info/LOG_LEVEL=warn/' "$W/kustomization.yaml"
kubectl apply -k "$W" && kubectl rollout status -n kust-17 deploy/api --timeout=120s
