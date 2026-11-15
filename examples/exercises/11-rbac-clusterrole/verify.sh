#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
SA=--as=system:serviceaccount:rbac-11:monitor
OPS="--as=bob --as-group=ops"
echo "Objects"
check "SA monitor"                     get sa monitor -n rbac-11
check "ClusterRole node-viewer"        get clusterrole node-viewer
check "CRB node-viewer -> ClusterRole node-viewer" eq "$(get clusterrolebinding node-viewer -o jsonpath='{.roleRef.name}')" node-viewer
check "CRB subjects: Group ops"        has "$(get clusterrolebinding node-viewer -o jsonpath='{range .subjects[*]}{.kind}/{.name} {end}')" Group/ops
check "CRB subjects: SA monitor"       has "$(get clusterrolebinding node-viewer -o jsonpath='{range .subjects[*]}{.kind}/{.namespace}/{.name} {end}')" ServiceAccount/rbac-11/monitor
check "Role app-config-reader uses resourceNames" eq "$(get role app-config-reader -n rbac-11 -o jsonpath='{.rules[*].resourceNames[*]}')" app-config
echo "SA monitor"
check "can list nodes"                 can list nodes $SA
check "can watch nodes"                can watch nodes $SA
check "cannot delete nodes"            no can delete nodes $SA
check "can list persistentvolumes"     can list persistentvolumes $SA
check "cannot delete persistentvolumes" no can delete persistentvolumes $SA
check "can get secret app-config"      can get secrets/app-config -n rbac-11 $SA
check "cannot get secret db-password"  no can get secrets/db-password -n rbac-11 $SA
check "cannot list secrets"            no can list secrets -n rbac-11 $SA
check "cannot update secret app-config" no can update secrets/app-config -n rbac-11 $SA
check "cannot get secrets in default"  no can get secrets/app-config -n default $SA
echo "Group ops (user bob)"
check "can list nodes"                 can list nodes $OPS
check "cannot get secret app-config"   no can get secrets/app-config -n rbac-11 $OPS
check "user bob without group cannot list nodes" no can list nodes --as=bob
summary
