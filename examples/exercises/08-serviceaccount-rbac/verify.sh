#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
AS=--as=system:serviceaccount:sa-08:pod-reader
echo "Objects"
check "SA pod-reader"                get sa pod-reader -n sa-08
check "Role read-pods"               get role read-pods -n sa-08
check "RoleBinding read-pods -> Role read-pods" eq "$(get rolebinding read-pods -n sa-08 -o jsonpath='{.roleRef.kind}/{.roleRef.name}')" Role/read-pods
check "RoleBinding view-other -> ClusterRole view" eq "$(get rolebinding view-other -n sa-08-other -o jsonpath='{.roleRef.kind}/{.roleRef.name}')" ClusterRole/view
check "no ClusterRoleBinding for pod-reader" no has "$(get clusterrolebinding -o jsonpath='{range .items[*]}{.subjects[*].name}{" "}{end}')" pod-reader
echo "Permissions"
check "can list pods in sa-08"       can list pods -n sa-08 $AS
check "can watch pods in sa-08"      can watch pods -n sa-08 $AS
check "can get pods/log in sa-08"    can get pods --subresource=log -n sa-08 $AS
check "cannot delete pods in sa-08"  no can delete pods -n sa-08 $AS
check "cannot list secrets in sa-08" no can list secrets -n sa-08 $AS
check "can list services in sa-08-other" can list services -n sa-08-other $AS
check "cannot list services in sa-08" no can list services -n sa-08 $AS
check "cannot list pods cluster-wide" no can list pods -A $AS
echo "Pod api-client"
check "runs as pod-reader"           eq "$(get pod api-client -n sa-08 -o jsonpath='{.spec.serviceAccountName}')" pod-reader
check "Running"                      eq "$(get pod api-client -n sa-08 -o jsonpath='{.status.phase}')" Running
check "logs contain a PodList"       has "$(kubectl logs api-client -n sa-08 2>/dev/null)" '"kind": "PodList"'
check "logs show no Forbidden"       no has "$(kubectl logs api-client -n sa-08 --tail=50 2>/dev/null)" Forbidden
summary
