#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; H="-n helm-15"
hist=$(helm history shop $H -o json 2>/dev/null)
cur=$(helm get values shop $H -o json 2>/dev/null)
r3=$(helm get values shop $H --revision 3 -o json 2>/dev/null)
echo "Chart"
check "work/webapp/Chart.yaml name webapp" grep -q '^name: webapp' "$W/webapp/Chart.yaml"
check "work/prod-values.yaml exists"   test -s "$W/prod-values.yaml"
echo "Release history"
check "at least 4 revisions"           test "$(jq length <<<"$hist" 2>/dev/null || echo 0)" -ge 4
check "revision 1 had replicaCount 2"  eq "$(helm get values shop $H --revision 1 -o json 2>/dev/null | jq -r .replicaCount)" 2
check "revision 3 kept replicaCount 3 (reuse values)" eq "$(jq -r .replicaCount <<<"$r3" 2>/dev/null)" 3
check "revision 3 had tag does-not-exist" eq "$(jq -r .image.tag <<<"$r3" 2>/dev/null)" does-not-exist
check "latest revision is a rollback to 2" has "$(jq -r '.[-1].description' <<<"$hist" 2>/dev/null)" "Rollback to 2"
check "current values: replicaCount 3, tag 1.27-alpine" eq "$(jq -r '"\(.replicaCount) \(.image.tag)"' <<<"$cur" 2>/dev/null)" "3 1.27-alpine"
echo "Cluster"
check "deploy shop-webapp 3/3 ready"   eq "$(get deploy shop-webapp $H -o jsonpath='{.spec.replicas}/{.status.readyReplicas}')" 3/3
check "image nginx:1.27-alpine"        eq "$(get deploy shop-webapp $H -o jsonpath='{.spec.template.spec.containers[0].image}')" nginx:1.27-alpine
echo "Template / package"
check "rendered.yaml has replicas: 4"  grep -q 'replicas: 4' "$W/rendered.yaml"
check "rendered.yaml uses 1.27-alpine" grep -q 'nginx:1.27-alpine' "$W/rendered.yaml"
check "nothing extra installed (only release shop)" eq "$(helm list $H -q 2>/dev/null)" shop
check "work/webapp-0.1.0.tgz exists"   test -s "$W/webapp-0.1.0.tgz"
summary
