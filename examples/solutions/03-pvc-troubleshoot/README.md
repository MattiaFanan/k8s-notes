# 03 – Solution

## Diagnosis
```bash
kubectl describe pod db -n storage-03      # persistentvolumeclaim "pvc-database" not found
kubectl get pvc -n storage-03              # pvc-db Pending
kubectl describe pvc pvc-db -n storage-03  # no persistent volumes available for this claim
kubectl get pv pv-db -o yaml               # 1Gi, ReadWriteOnce, storageClassName slow
```
Three bugs:
1. The pod refers to the claim `pvc-database`, but the claim is called `pvc-db`.
2. The PVC asks for `2Gi`, but the PV has only `1Gi` (a PV must be >= the request).
3. The PVC asks for `ReadWriteMany`, but the PV offers only `ReadWriteOnce`.

(`storageClassName: slow` matches, and no StorageClass object `slow` is needed for static binding.)

## Fix
A PVC spec is almost entirely immutable (you can only *increase* size, on expandable classes), and
pod volumes are immutable. So **delete and recreate** both:
```bash
kubectl get pvc pvc-db -n storage-03 -o yaml > pvc.yaml   # edit: RWO, 1Gi, strip status/uid/etc
kubectl get pod db -n storage-03 -o yaml > pod.yaml       # edit: claimName pvc-db
kubectl delete pod db -n storage-03 --force --grace-period=0
kubectl delete pvc pvc-db -n storage-03
kubectl apply -f pvc.yaml -f pod.yaml
```
`kubectl replace --force -f pod.yaml` does delete + create in one step.

Tip: you can tie a PVC to one PV directly with `spec.volumeName: pv-db`.
