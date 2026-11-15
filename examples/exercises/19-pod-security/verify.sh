#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; N="-n psa-19"
L() { get ns psa-19 -o jsonpath="{.metadata.labels.pod-security\.kubernetes\.io/$1}"; }
c() { get pod secure $N -o jsonpath="{.spec.containers[0].securityContext.$1}"; }
echo "Namespace labels"
check "enforce=restricted"            eq "$(L enforce)" restricted
check "warn=restricted"               eq "$(L warn)" restricted
check "bad-pod.yaml is rejected"      no kubectl apply --dry-run=server -f "$W/bad-pod.yaml"
check "bad pod does not exist"        no get pod bad $N
echo "Pod secure"
check "Running"                       eq "$(get pod secure $N -o jsonpath='{.status.phase}')" Running
check "readOnlyRootFilesystem"        eq "$(c readOnlyRootFilesystem)" true
check "allowPrivilegeEscalation false" eq "$(c allowPrivilegeEscalation)" false
check "capabilities drop ALL"         eq "$(c capabilities.drop[*])" ALL
check "runs as uid 101"               has "$(kubectl exec $N secure -- id 2>/dev/null)" "uid=101"
check "root fs really read-only"      no kubectl exec $N secure -- touch /etc/x
check "/tmp writable"                 kubectl exec $N secure -- touch /tmp/x
check "serves on 8080"                has "$(kubectl exec $N secure -- wget -qO- 127.0.0.1:8080 2>/dev/null)" nginx
echo "Pod ids"
ID=$(kubectl exec $N ids -- id 2>/dev/null)
check "uid=1000"                      has "$ID" "uid=1000"
check "gid=3000"                      has "$ID" "gid=3000"
check "groups include 2000"           has "$ID" "2000"
check "/data group-owned by 2000"     eq "$(kubectl exec $N ids -- stat -c %g /data 2>/dev/null)" 2000
check "set at pod level"              eq "$(get pod ids $N -o jsonpath='{.spec.securityContext.runAsUser}/{.spec.securityContext.runAsGroup}/{.spec.securityContext.fsGroup}')" 1000/3000/2000
summary
