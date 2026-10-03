# Debug and fix a CrashLoopBackOff / Pending pod

**Task:** Pod `broken` is stuck in `CrashLoopBackOff` (or `Pending`/`ImagePullBackOff`) — find the cause and fix it.

**Fastest route — triage order:**
```bash
k get pod broken -o wide                  # STATUS column: which failure mode?
k describe pod broken                     # bottom Events: the actual reason
k logs broken                             # app-level error (if it started at all)
k logs broken --previous                  # logs from the crashed instance
```

**Common causes → fix:**
| Symptom in `describe` | Fix |
|---|---|
| `ImagePullBackOff` / `ErrImagePull` | Typo'd image tag/name → `k set image pod/broken <container>=<correct-image>` (pods are immutable for image on some fields — may need delete+recreate) |
| `Insufficient cpu/memory` (Pending) | Lower `resources.requests` or scale down elsewhere |
| `CrashLoopBackOff` + exit code 1 | Check `command`/`args` typo, or missing env var/configmap key — `k logs --previous` |
| `CreateContainerConfigError` | Referenced ConfigMap/Secret key doesn't exist — `k get cm/secret -o yaml` to confirm key names |
| `readinessProbe`/`livenessProbe` failing | Wrong port/path in probe — `k describe pod` Events show probe failures explicitly |

**Verify fix:**
```bash
k get pod broken -w
k exec broken -- <sanity-check-command>
```

**Gotcha:** most pod spec fields (image is one narrow exception via `kubectl set image`, others are not) are immutable after creation — if editing YAML in place gives "field is immutable," delete and reapply: `k delete pod broken --force --grace-period=0 && k apply -f pod.yaml`.
