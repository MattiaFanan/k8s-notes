#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n deploy-22"
d() { get deploy "$1" $N -o jsonpath="$2"; }
echo "Blue/green"
check "green 2/2 ready, answers v2"   eq "$(d green '{.status.readyReplicas} {.spec.template.spec.containers[0].args[0]}')" "2 -text=v2"
check "service shop selects version=green" eq "$(get svc shop $N -o jsonpath='{.spec.selector.version}')" green
check "shop endpoints = green pods"   eq "$(svc_ips deploy-22 shop)" "$(pod_ips deploy-22 app=shop,version=green)"
check "blue still running"            eq "$(d blue '{.status.readyReplicas}')" 2
echo "Canary"
check "catalog-canary 1 replica, track=canary, catalog-v2" eq "$(d catalog-canary '{.spec.replicas} {.spec.template.metadata.labels.track} {.spec.template.spec.containers[0].args[0]}')" "1 canary -text=catalog-v2"
check "service catalog unchanged (app=catalog only)" eq "$(get svc catalog $N -o jsonpath='{.spec.selector}')" '{"app":"catalog"}'
check "catalog has 5 endpoints (4 stable + 1 canary)" eq "$(svc_ips deploy-22 catalog | wc -w)" 5
echo "Rolling update / rollback"
check "maxSurge 1, maxUnavailable 0"  eq "$(d catalog '{.spec.strategy.type} {.spec.strategy.rollingUpdate.maxSurge} {.spec.strategy.rollingUpdate.maxUnavailable}')" "RollingUpdate 1 0"
check "rolled back: answers catalog-v1" eq "$(d catalog '{.spec.template.spec.containers[0].args[0]}')" -text=catalog-v1
check "at least revision 3 (update + rollback)" test "$(d catalog '{.metadata.annotations.deployment\.kubernetes\.io/revision}')" -ge 3
check "history has cause 'bump to v1.1'" has "$(kubectl rollout history deploy/catalog $N 2>/dev/null)" "bump to v1.1"
check "catalog 4/4 ready"             eq "$(d catalog '{.status.readyReplicas}')" 4
summary
