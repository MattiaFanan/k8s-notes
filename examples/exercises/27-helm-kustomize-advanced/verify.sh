#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; P="$W/platform"
d() { get deploy "$2" -n "$1" -o jsonpath="$3"; }
echo "Chart"
check "Chart.yaml depends on backend"  grep -q 'name: backend' "$P/Chart.yaml"
check "repository file://../backend"   grep -q 'file://../backend' "$P/Chart.yaml"
check "condition backend.enabled"      grep -q 'condition: backend.enabled' "$P/Chart.yaml"
check "charts/backend-0.1.0.tgz fetched" test -s "$P/charts/backend-0.1.0.tgz"
check "backend.enabled=false drops plat-backend" no grep -q 'name: plat-backend' <(helm template plat "$P" --set backend.enabled=false 2>/dev/null)
echo "Release plat (helm-27)"
check "deployed"                       eq "$(helm status plat -n helm-27 -o json 2>/dev/null | jq -r .info.status)" deployed
check "plat-platform 1/1"              eq "$(d helm-27 plat-platform '{.spec.replicas}/{.status.readyReplicas}')" 1/1
check "plat-backend 2/2"               eq "$(d helm-27 plat-backend '{.spec.replicas}/{.status.readyReplicas}')" 2/2
check "plat-backend image nginx:1.27-alpine" eq "$(d helm-27 plat-backend '{.spec.template.spec.containers[0].image}')" nginx:1.27-alpine
echo "kustomize (helm-27-kust)"
check "rendered.yaml has no test pods"  no grep -q 'helm.sh/hook: test' "$W/kust/rendered.yaml"
check "plat-platform 3/3"              eq "$(d helm-27-kust plat-platform '{.spec.replicas}/{.status.readyReplicas}')" 3/3
check "label rendered-by=kustomize"    eq "$(d helm-27-kust plat-platform '{.metadata.labels.rendered-by}')" kustomize
check "label not in selector"          eq "$(d helm-27-kust plat-platform '{.spec.selector.matchLabels.rendered-by}')" ""
check "plat-backend 2 replicas there too" eq "$(d helm-27-kust plat-backend '{.spec.replicas}')" 2
check "no helm release in helm-27-kust" eq "$(helm list -n helm-27-kust -q 2>/dev/null)" ""
summary
