# Pod/container securityContext hardening

**Task:** Pod `secure-pod` must run as non-root UID 1000, GID 3000, filesystem group 2000, container root filesystem read-only, drop the `NET_RAW` capability.

**Fastest route:**
```bash
k run secure-pod --image=nginx $do > pod.yaml
```
Edit — pod-level (applies to all containers):
```yaml
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: secure-pod
    image: nginx
    securityContext:
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["NET_RAW"]
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k exec secure-pod -- id
k exec secure-pod -- touch /test    # should fail: Read-only file system
```

**Gotcha:** nginx normally needs to write to `/var/cache/nginx` and `/var/run` — with `readOnlyRootFilesystem: true` it may CrashLoop unless those paths are separate `emptyDir` mounts. If the exam only asks to *set* the field (not keep the pod healthy), don't over-engineer extra volumes — just set it and verify with `describe`/`exec` as asked.
