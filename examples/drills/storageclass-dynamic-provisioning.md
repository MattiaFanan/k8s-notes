# StorageClass: dynamic PVC provisioning instead of a static PV

**Task:** Instead of pre-creating a PV, request storage via a StorageClass so the cluster provisions it on demand. Also find/set the default StorageClass.

**Fastest route — discover:**
```bash
k get storageclass                       # (default) marker shown next to the default one
k get sc -o yaml | grep -A2 is-default-class
```

**Set/clear the default (same annotation pattern as IngressClass):**
```bash
k patch storageclass standard -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
k patch storageclass other -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

**PVC using dynamic provisioning — no PV created by hand:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dyn-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: standard      # omit entirely to use whatever is marked default
  resources:
    requests:
      storage: 2Gi
```
```bash
k apply -f pvc.yaml
```

**Verify:**
```bash
k get pvc dyn-pvc                # STATUS: Bound (provisioner creates the PV automatically)
k get pv                         # a new PV appears, named dynamically, bound to the PVC
k describe pvc dyn-pvc | grep -i storageclass
```

**Gotcha — the exam trap:** `storageClassName: ""` (explicit empty string) means "no dynamic provisioning, static PVs only" — that's different from omitting the field, which means "use the cluster default." If a PVC stays `Pending` forever, check three things in order: does any StorageClass exist at all (`k get sc`), does the requested class name actually exist (typo?), and does the provisioner behind it support the requested `accessModes` (e.g. many cloud block-storage provisioners only do `ReadWriteOnce`, not `ReadWriteMany`).
