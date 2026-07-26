# Storage - CKAD Exam Tips

## Shortcuts
- For distribution questions, generate PVC first, then use `volumeMounts` with PVC name in Pod.
- `emptyDir` is fastest for data sharing between containers in same Pod.

## Pitfalls
1. **Access mode mismatch**: `ReadWriteOnce` incompatible with ReadOnlyMany / ReadWriteMany use cases.
2. **Namespace**: PVs are cluster-scoped; PVCs and Pods are namespace-scoped.
3. **StorageClassName**: Matching StorageClass names required for dynamic binding.
4. **Forgetting mount**: Forgetting `volumeMounts` in container while declaring `volumes` makes storage inaccessible.

## Time-Saver
```bash
# Quick emptyDir volume in Pod YAML:
volumes:
- name: scratch
  emptyDir: {}
# In container:
volumeMounts:
- name: scratch
  mountPath: /tmp
```
