# 13 – Solution

```bash
kubectl apply -f statefulset.yaml
kubectl get pods,pvc -n sts-13 -w            # pods start in order: db-0, db-1, db-2
kubectl delete pod db-1 -n sts-13            # comes back with the same name and the same PVC
kubectl exec -n sts-13 db-1 -- cat /data/boots          # 2 lines
kubectl exec -n sts-13 db-0 -- nslookup db-1.db.sts-13.svc.cluster.local
kubectl scale sts db -n sts-13 --replicas=2  # db-2 removed, and data-db-2 deleted because whenScaled: Delete
kubectl apply -f scratch-pod.yaml
kubectl get pvc -n sts-13                    # scratch-work
```
No `kubectl create statefulset` exists. Start from `kubectl create deploy db --image=busybox:1.36 --dry-run=client -o yaml`,
change `kind`, add `serviceName` and `volumeClaimTemplates`, and remove `strategy`.

## Answers
- PVC names are `<template name>-<pod name>`: `data-db-0`, `data-db-1`, `data-db-2`. A pod always gets the PVC
  with its own ordinal back, which is why `db-1` still sees its data after it was deleted.
- `persistentVolumeClaimRetentionPolicy` (default `Retain`/`Retain`) decides what happens to those PVCs when the
  StatefulSet is deleted (`whenDeleted`) or scaled down (`whenScaled`). With `Retain`, scaling back up reuses the old data.
- **Generic ephemeral volume**: the PVC is named `<pod>-<volume>` (`scratch-work`). Its ownerReference is the Pod,
  so it is garbage-collected when the pod is deleted. Unlike `emptyDir`, it uses a StorageClass, so you get a real
  size limit, the storage class's features (snapshots, a specific disk type), and storage that does not come from the node's root disk.
  Unlike a StatefulSet template, the data does **not** survive pod recreation.
- Headless Service + `serviceName`: each pod gets the DNS name `db-0.db.sts-13.svc.cluster.local`. The name of a StatefulSet's headless Service
  must match `serviceName`.
- busybox `nslookup` ignores the `search` list in `/etc/resolv.conf`, so `nslookup db-1.db` fails there even though
  the record exists. Use the full name, or `getent hosts db-1.db` / `ping db-1.db`, which do use the search list.
