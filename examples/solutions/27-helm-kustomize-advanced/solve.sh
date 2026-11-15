#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(cd "$(dirname "$0")" && pwd); W="$D/../../exercises/27-helm-kustomize-advanced/work"; mkdir -p "$W/kust"; cd "$W"
helm create backend >/dev/null; helm create platform >/dev/null
cat "$D/Chart-dependencies.yaml" >> platform/Chart.yaml
cat "$D/values-backend.yaml" >> platform/values.yaml
helm dependency update platform
helm install plat ./platform -n helm-27 --wait
helm template plat ./platform --skip-tests > kust/rendered.yaml
cp "$D/kustomization.yaml" kust/
kubectl apply -k kust
kubectl rollout status deploy/plat-platform -n helm-27-kust --timeout=120s
