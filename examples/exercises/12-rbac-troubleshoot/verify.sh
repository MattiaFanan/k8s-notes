#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n rbac-12"; A=--as=system:serviceaccount:rbac-12:ci-bot
echo "Allowed in rbac-12"
for v in get list watch create update patch; do check "$v deployments" can $v deployments.apps $N $A; done
for v in get update patch; do check "$v deployments/scale" can $v deployments.apps --subresource=scale $N $A; done
check "get pods"                       can get pods $N $A
check "list pods"                      can list pods $N $A
check "get pods/log"                   can get pods --subresource=log $N $A
check "kubectl scale works (server dry-run)" kubectl scale deploy app --replicas=2 --dry-run=server $N $A
echo "Denied"
check "cannot delete deployments"      no can delete deployments.apps $N $A
check "cannot get secrets"             no can get secrets $N $A
check "cannot list secrets"            no can list secrets $N $A
check "cannot delete pods"             no can delete pods $N $A
check "cannot list deployments in default" no can list deployments.apps -n default $A
check "cannot list deployments cluster-wide" no can list deployments.apps -A $A
echo "Objects"
check "Role ci-deployer exists"        get role ci-deployer $N
check "RoleBinding ci-deployer exists" get rolebinding ci-deployer $N
check "pod ci-runner uses ci-bot"      eq "$(get pod ci-runner $N -o jsonpath='{.spec.serviceAccountName}')" ci-bot
check "pod ci-runner image busybox:1.36" eq "$(get pod ci-runner $N -o jsonpath='{.spec.containers[0].image}')" busybox:1.36
check "pod ci-runner Running"          eq "$(get pod ci-runner $N -o jsonpath='{.status.phase}')" Running
summary
