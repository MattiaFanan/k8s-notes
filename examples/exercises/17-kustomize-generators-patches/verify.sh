#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; N="-n kust-17"
d() { get deploy api $N -o jsonpath="$1"; }
x() { kubectl exec $N deploy/api -- "$@" 2>/dev/null; }
echo "Files"
check "deployment.yaml unchanged (replicas 1)" grep -q 'replicas: 1' "$W/deployment.yaml"
check "kustomization builds"           kubectl kustomize "$W"
check "patch-resources.yaml used"      grep -q patch-resources.yaml "$W/kustomization.yaml"
echo "Deployment api"
check "2/2 ready"                      eq "$(d '{.spec.replicas}/{.status.readyReplicas}')" 2/2
check "requests cpu 50m memory 32Mi"   eq "$(d '{.spec.template.spec.containers[0].resources.requests.cpu}/{.spec.template.spec.containers[0].resources.requests.memory}')" 50m/32Mi
check "limit memory 64Mi"              eq "$(d '{.spec.template.spec.containers[0].resources.limits.memory}')" 64Mi
check "configMapRef is hashed api-config-*" has "$(d '{.spec.template.spec.containers[0].envFrom[0].configMapRef.name}')" api-config-
check "volume uses the same ConfigMap"  eq "$(d '{.spec.template.spec.volumes[0].configMap.name}')" "$(d '{.spec.template.spec.containers[0].envFrom[0].configMapRef.name}')"
check "rolled out at least twice (revision >= 2)" test "$(d '{.metadata.annotations.deployment\.kubernetes\.io/revision}')" -ge 2
echo "Inside the pod"
check "LOG_LEVEL=warn"                 eq "$(x printenv LOG_LEVEL)" warn
check "DB_PASSWORD=changeme"           eq "$(x printenv DB_PASSWORD)" changeme
check "/etc/api/settings.json mounted" has "$(x cat /etc/api/settings.json)" beta
echo "Generated objects"
check "ConfigMap api-static (no hash) OWNER=team-a" eq "$(get cm api-static $N -o jsonpath='{.data.OWNER}')" team-a
check "old api-config-* still exists (2+)" test "$(get cm $N -o name | grep -c 'api-config-')" -ge 2
check "secret api-secret-* exists"     has "$(get secret $N -o name)" secret/api-secret-
summary
