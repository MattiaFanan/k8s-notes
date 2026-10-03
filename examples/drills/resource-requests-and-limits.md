# Set CPU/memory requests and limits on a pod

**Task:** Create pod `constrained` with image `nginx`, requesting 100m CPU / 128Mi memory, limited to 250m CPU / 256Mi memory.

**Fastest route:**
```bash
k run constrained --image=nginx \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=250m,memory=256Mi
```
(No `--dry-run` needed — this flag combo applies directly via `kubectl run`.)

**Verify:**
```bash
k get pod constrained -o jsonpath='{.spec.containers[0].resources}'
```

**Gotcha:** if the pod already exists, resources can't be patched in-place on a running pod (only Deployments allow smooth edits) — delete and recreate, or edit a Deployment's pod template and let the rollout replace pods. Also watch memory unit: `Mi` not `MB`.
