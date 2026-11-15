#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=storage-03
echo "PV pv-db untouched"
check "same PV object (not recreated)" eq "$(get pv pv-db -o jsonpath='{.metadata.uid}')" "$(get cm setup-info -n $N -o jsonpath='{.data.pv-uid}')"
check "still 1Gi RWO"          eq "$(get pv pv-db -o jsonpath='{.spec.capacity.storage} {.spec.accessModes[*]}')" "1Gi ReadWriteOnce"
echo "PVC pvc-db"
check "Bound"                  eq "$(get pvc pvc-db -n $N -o jsonpath='{.status.phase}')" Bound
check "bound to pv-db"         eq "$(get pvc pvc-db -n $N -o jsonpath='{.spec.volumeName}')" pv-db
echo "Pod db"
check "Running"                eq "$(get pod db -n $N -o jsonpath='{.status.phase}')" Running
check "uses claim pvc-db"      eq "$(get pod db -n $N -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}')" pvc-db
check "image busybox:1.36"     eq "$(get pod db -n $N -o jsonpath='{.spec.containers[0].image}')" busybox:1.36
check "/data/db.log written"   kubectl exec -n $N db -- test -s /data/db.log
summary
