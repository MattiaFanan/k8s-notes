# Find and fix a deprecated API version in a manifest

**Task:** `old.yaml` uses a deprecated/removed apiVersion (e.g. `extensions/v1beta1` for a Deployment). Fix it so `kubectl apply` succeeds on the current cluster.

**Fastest route:**
```bash
k apply -f old.yaml --dry-run=server    # errors show exactly which apiVersion is invalid

k api-resources | grep -i deployment    # shows the current correct APIVERSION column
k explain deployment                    # top line confirms current group/version, e.g. apps/v1
```
Edit `old.yaml`, change only the `apiVersion:` line (resource `kind`/fields usually still apply, occasionally a field also moved — `k explain <kind>.<field>` to confirm):
```yaml
apiVersion: apps/v1   # was: extensions/v1beta1
```
```bash
k apply -f old.yaml
```

**Verify:**
```bash
k get deploy <name>
```

**Gotcha:** `apps/v1` Deployments require `spec.selector` to be explicitly set (older betas defaulted it) — if apply fails with "selector is required," add:
```yaml
spec:
  selector:
    matchLabels:
      app: <same-label-as-pod-template>
```
