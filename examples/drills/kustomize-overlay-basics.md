# Build a Kustomize base + overlay and apply it

**Task:** `base/` has a deployment + kustomization.yaml. Create an `overlays/prod/` that bumps replicas to 5 and adds a common label `env=prod`.

**Fastest route:**
```bash
mkdir -p overlays/prod
```
`overlays/prod/kustomization.yaml`:
```yaml
resources:
  - ../../base
replicas:
  - name: web            # must match the Deployment's metadata.name in base
    count: 5
commonLabels:
  env: prod
```
```bash
k apply -k overlays/prod
```

**Verify:**
```bash
k kustomize overlays/prod   # renders final YAML without applying — sanity check first
k get deploy web -o yaml | grep -A1 replicas
k get deploy web --show-labels
```

**Gotcha:** always dry-render with `k kustomize <dir>` before `apply -k` — catches path typos in `resources:` before touching the cluster. `replicas:` patch by name only works on Deployments/StatefulSets already defined by that exact name in the base.
