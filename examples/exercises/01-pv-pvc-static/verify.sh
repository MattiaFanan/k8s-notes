#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=storage-01
pv() { get pv pv-logs -o jsonpath="$1"; }
pvc() { get pvc pvc-logs -n $N -o jsonpath="$1"; }
po() { get pod logger -n $N -o jsonpath="$1"; }
echo "PV pv-logs"
check "exists"                 get pv pv-logs
check "capacity 200Mi"         eq "$(pv '{.spec.capacity.storage}')" 200Mi
check "accessModes RWO"        eq "$(pv '{.spec.accessModes[*]}')" ReadWriteOnce
check "reclaimPolicy Retain"   eq "$(pv '{.spec.persistentVolumeReclaimPolicy}')" Retain
check "storageClassName manual" eq "$(pv '{.spec.storageClassName}')" manual
check "label tier=logs"        eq "$(pv '{.metadata.labels.tier}')" logs
check "hostPath /tmp/ckad/pv-logs" eq "$(pv '{.spec.hostPath.path}')" /tmp/ckad/pv-logs
echo "PVC pvc-logs"
check "requests 100Mi"         eq "$(pvc '{.spec.resources.requests.storage}')" 100Mi
check "selector tier=logs"     eq "$(pvc '{.spec.selector.matchLabels.tier}')" logs
check "Bound"                  eq "$(pvc '{.status.phase}')" Bound
check "bound to pv-logs"       eq "$(pvc '{.spec.volumeName}')" pv-logs
echo "Pod logger"
check "Running"                eq "$(po '{.status.phase}')" Running
check "uses claim pvc-logs"    eq "$(po '{.spec.volumes[*].persistentVolumeClaim.claimName}')" pvc-logs
check "mounted at /var/log/app" has "$(po '{.spec.containers[0].volumeMounts[*].mountPath}')" /var/log/app
check "out.log is being written" kubectl exec -n $N logger -- sh -c 'test -s /var/log/app/out.log'
summary
