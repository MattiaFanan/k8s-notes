# 19 – Solution

```bash
kubectl label ns psa-19 pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest pod-security.kubernetes.io/warn=restricted
kubectl apply -f work/bad-pod.yaml
# Error ... violates PodSecurity "restricted:latest": host namespaces (hostNetwork=true), privileged (container "c"
#   must not set securityContext.privileged=true), allowPrivilegeEscalation != false, unrestricted capabilities,
#   runAsNonRoot != true, runAsUser=0, seccompProfile ...
kubectl apply -f pods.yaml
kubectl exec -n psa-19 ids -- id          # uid=1000 gid=3000 groups=2000,3000
kubectl exec -n psa-19 ids -- ls -ld /data   # group 2000
```

## Key points
- **Pod Security Admission** is configured with namespace labels
  `pod-security.kubernetes.io/<mode>=<level>`. Modes: `enforce` (reject), `audit` (audit log), `warn` (warning to the client).
  Levels: `privileged` < `baseline` (no hostNetwork/privileged/hostPath...) < `restricted` (also non-root, drop ALL,
  no privilege escalation, seccomp RuntimeDefault/Localhost).
- `enforce` checks **pods**. A Deployment with bad pods is still created, but its ReplicaSet cannot make pods.
  Look at `kubectl describe rs` or `kubectl get events`. The `warn` label shows a warning when you apply the Deployment.
- Existing pods are not evicted when you add the label. Test first with
  `kubectl label --dry-run=server --overwrite ns psa-19 pod-security.kubernetes.io/enforce=restricted`.
- **Pod vs container securityContext**: `runAsUser`, `runAsGroup`, `runAsNonRoot`, `seccompProfile` work on both levels
  (container wins). `fsGroup` and `supplementalGroups` are pod-level only. `capabilities`, `privileged`,
  `allowPrivilegeEscalation`, `readOnlyRootFilesystem` are container-level only.
- `runAsNonRoot: true` with an image whose user is a *name* (not a number) fails with "cannot verify user is non-root".
  Set `runAsUser` to a number.
- `readOnlyRootFilesystem: true` usually needs `emptyDir` mounts for the paths the app writes (`/tmp`, cache, pid files).
