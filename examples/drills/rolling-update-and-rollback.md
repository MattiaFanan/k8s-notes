# Rolling update a deployment image and roll back

**Task:** Deployment `web` is on `nginx:1.24`. Update to `nginx:1.25`, record the change, then roll back to the previous version because it broke.

**Fastest route:**
```bash
k set image deployment/web nginx=nginx:1.25 --record
k rollout status deployment/web
```
Broke it? Roll back:
```bash
k rollout history deployment/web              # find revision number if needed
k rollout undo deployment/web                 # goes to previous revision
k rollout undo deployment/web --to-revision=2 # or a specific one
```

**Verify:**
```bash
k rollout status deployment/web
k get deploy web -o jsonpath='{.spec.template.spec.containers[0].image}'
```

**Gotcha:** Container name in `set image` must match the exact container name (`k get deploy web -o jsonpath='{.spec.template.spec.containers[*].name}'` if unsure). `--record` is deprecated in newer kubectl but still accepted; history annotation comes from `kubernetes.io/change-cause` — set explicitly if needed:
```bash
k annotate deployment/web kubernetes.io/change-cause="update to 1.25" --overwrite
```
