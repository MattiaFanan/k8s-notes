#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n sts-13"
sts() { get sts db $N -o jsonpath="$1"; }
echo "Service db"
check "headless (clusterIP None)"      eq "$(get svc db $N -o jsonpath='{.spec.clusterIP}')" None
echo "StatefulSet db"
check "serviceName db"                 eq "$(sts '{.spec.serviceName}')" db
check "scaled to 2, 2 ready"           eq "$(sts '{.spec.replicas}/{.status.readyReplicas}')" 2/2
check "template data 32Mi local-path"  eq "$(sts '{.spec.volumeClaimTemplates[?(@.metadata.name=="data")].spec.resources.requests.storage}/{.spec.volumeClaimTemplates[0].spec.storageClassName}')" 32Mi/local-path
check "whenDeleted Retain"             eq "$(sts '{.spec.persistentVolumeClaimRetentionPolicy.whenDeleted}')" Retain
check "whenScaled Delete"              eq "$(sts '{.spec.persistentVolumeClaimRetentionPolicy.whenScaled}')" Delete
check "PVC data-db-0 Bound"            eq "$(get pvc data-db-0 $N -o jsonpath='{.status.phase}')" Bound
check "PVC data-db-1 Bound"            eq "$(get pvc data-db-1 $N -o jsonpath='{.status.phase}')" Bound
check "PVC data-db-2 gone after scale-down" no get pvc data-db-2 $N
check "db-1 /data/hostname is db-1"    eq "$(kubectl exec $N db-1 -- cat /data/hostname 2>/dev/null)" db-1
check "db-1 restarted, data kept (>=2 boots)" test "$(kubectl exec $N db-1 -- sh -c 'wc -l < /data/boots' 2>/dev/null || echo 0)" -ge 2
check "db-0 resolves db-1.db.sts-13.svc.cluster.local" kubectl exec $N db-0 -- nslookup db-1.db.sts-13.svc.cluster.local
echo "Pod scratch (generic ephemeral)"
check "Running"                        eq "$(get pod scratch $N -o jsonpath='{.status.phase}')" Running
check "volume work is ephemeral 16Mi"  eq "$(get pod scratch $N -o jsonpath='{.spec.volumes[?(@.name=="work")].ephemeral.volumeClaimTemplate.spec.resources.requests.storage}')" 16Mi
check "PVC scratch-work owned by pod scratch" eq "$(get pvc scratch-work $N -o jsonpath='{.metadata.ownerReferences[0].kind}/{.metadata.ownerReferences[0].name}')" Pod/scratch
check "mounted at /scratch"            kubectl exec $N scratch -- sh -c 'mount | grep -q " /scratch "'
summary
