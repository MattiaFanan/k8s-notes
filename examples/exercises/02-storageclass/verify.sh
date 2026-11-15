#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=storage-02
sc() { get sc local-retain -o jsonpath="$1"; }
echo "StorageClass local-retain"
check "exists"                     get sc local-retain
check "provisioner rancher.io/local-path" eq "$(sc '{.provisioner}')" rancher.io/local-path
check "reclaimPolicy Retain"       eq "$(sc '{.reclaimPolicy}')" Retain
check "WaitForFirstConsumer"       eq "$(sc '{.volumeBindingMode}')" WaitForFirstConsumer
check "not default"                no eq "$(sc '{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')" true
check "local-path still default"   eq "$(get sc local-path -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')" true
echo "PVC web-data + Deployment web"
check "web-data class local-retain" eq "$(get pvc web-data -n $N -o jsonpath='{.spec.storageClassName}')" local-retain
check "web-data Bound"             eq "$(get pvc web-data -n $N -o jsonpath='{.status.phase}')" Bound
PV=$(get pvc web-data -n $N -o jsonpath='{.spec.volumeName}')
check "dynamic PV has Retain"      eq "$(get pv "$PV" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')" Retain
check "deployment web available"   eq "$(get deploy web -n $N -o jsonpath='{.status.availableReplicas}')" 1
check "deployment uses web-data"   has "$(get deploy web -n $N -o jsonpath='{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}')" web-data
check "index.html says 'hello from pv'" has "$(kubectl exec -n $N deploy/web -- cat /usr/share/nginx/html/index.html 2>/dev/null)" "hello from pv"
echo "PVC scratch"
check "scratch got default class local-path" eq "$(get pvc scratch -n $N -o jsonpath='{.spec.storageClassName}')" local-path
summary
