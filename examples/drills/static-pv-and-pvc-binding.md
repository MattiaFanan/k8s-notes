# Static PersistentVolume bound by a PVC, mounted in a pod

**Task:** Create a 1Gi hostPath PV `data-pv`, a PVC `data-pvc` requesting 1Gi that binds to it, and a pod mounting the PVC.

**Fastest route:** no imperative create for PV/PVC — minimal YAML.

`pv.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-pv
spec:
  capacity:
    storage: 1Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /mnt/data
  persistentVolumeReclaimPolicy: Retain
```
`pvc.yaml`:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
```
```bash
k apply -f pv.yaml -f pvc.yaml
```
Pod:
```bash
k run pv-pod --image=nginx $do > pod.yaml
```
Add:
```yaml
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
  containers:
  - name: pv-pod
    volumeMounts:
    - name: data
      mountPath: /usr/share/data
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k get pv data-pv        # STATUS: Bound
k get pvc data-pvc      # STATUS: Bound, same volume name
k exec pv-pod -- df -h /usr/share/data
```

**Gotcha:** PVC binds to a PV only if `accessModes` match and requested `storage` <= PV capacity — mismatched accessModes is the #1 reason a PVC stays `Pending`. No `storageClassName` on either side means both default to `""` and match on that basis; if a `StorageClass` exists with default annotation, PVC without an explicit class will pick that up instead of your static PV, causing a phantom Pending — set `storageClassName: ""` explicitly on both to force static binding.
