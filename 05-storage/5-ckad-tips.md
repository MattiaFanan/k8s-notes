# Storage - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- For distribution questions, generate PVC first, then use `volumeMounts` with PVC name in Pod.
- `emptyDir` is fastest for data sharing between containers in same Pod.
- Use `kubectl get pv` and `kubectl get pvc` to verify storage resources.
- Use `kubectl get storageclass` to list available StorageClasses.
- Use `kubectl get sc` as shorthand for `kubectl get storageclass`.

## Pitfalls
1. **Access mode mismatch**: `ReadWriteOnce` incompatible with ReadOnlyMany / ReadWriteMany use cases.
2. **Namespace**: PVs are cluster-scoped; PVCs and Pods are namespace-scoped.
3. **StorageClassName**: Matching StorageClass names required for dynamic binding.
4. **Forgetting mount**: Forgetting `volumeMounts` in container while declaring `volumes` makes storage inaccessible.
5. **`volumeBindingMode: WaitForFirstConsumer`**: Delays PV binding until a pod uses the PVC. This can cause scheduling issues if the pod's node doesn't have the right storage.
6. **`persistentVolumeReclaimPolicy: Retain`**: Data persists after PVC deletion. You must manually clean up the PV.
7. **Ephemeral volumes**: CSI ephemeral volumes are in CKAD scope (DB-04). Know the `ephemeral` volume type.

## Time-Saver
```bash
alias k=kubectl

# Quick emptyDir volume in Pod YAML:
volumes:
- name: scratch
  emptyDir: {}
# In container:
volumeMounts:
- name: scratch
  mountPath: /tmp

# Quick PVC creation
k create pvc my-pvc --storage-class=fast --size=1Gi --access-mode=ReadWriteOnce

# Verify storage resources
k get pv
k get pvc
k get sc
```

## See also

- [Storage YAML Structure](1-yaml-structure.md)
- [Access Modes](2-mechanics/01-access-modes.md)
- [Reclaim Policies](2-mechanics/03-reclaim-policies.md)
- [Volume Lifecycle & Binding](2-mechanics/04-volume-lifecycle-binding.md)
