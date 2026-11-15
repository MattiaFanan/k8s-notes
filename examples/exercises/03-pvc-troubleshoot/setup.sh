#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns storage-03
kubectl apply -f - <<'YAML'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-db
spec:
  capacity: {storage: 1Gi}
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: slow
  hostPath: {path: /tmp/ckad/pv-db, type: DirectoryOrCreate}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: pvc-db, namespace: storage-03}
spec:
  storageClassName: slow
  accessModes: [ReadWriteMany]
  resources: {requests: {storage: 2Gi}}
---
apiVersion: v1
kind: Pod
metadata: {name: db, namespace: storage-03}
spec:
  containers:
  - name: db
    image: busybox:1.36
    command: ["sh", "-c", "echo started > /data/db.log; sleep 3600"]
    volumeMounts: [{name: data, mountPath: /data}]
  volumes:
  - name: data
    persistentVolumeClaim: {claimName: pvc-database}
YAML
# remember the PV identity so verify can tell if it was recreated
kubectl create configmap setup-info -n storage-03 --from-literal=pv-uid="$(kubectl get pv pv-db -o jsonpath='{.metadata.uid}')" \
  --dry-run=client -o yaml | kubectl apply -f -
