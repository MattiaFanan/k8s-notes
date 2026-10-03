# Apply a CRD and create a custom resource from it

**Task:** A CRD manifest exists at `crd.yaml` (e.g., defines kind `Website`, group `example.com/v1`). Apply it, then create a custom resource using it.

**Fastest route:**
```bash
k apply -f crd.yaml
k get crd | grep website     # confirm it's Established
```
`cr.yaml` (shape comes from the CRD's `spec.versions[].schema`):
```yaml
apiVersion: example.com/v1
kind: Website
metadata:
  name: my-site
spec:
  domain: example.com
  replicas: 2
```
```bash
k apply -f cr.yaml
```

**Verify:**
```bash
k get websites
k describe website my-site
```

**Gotcha:** never hand-write a CR's `spec` fields from guesswork — always `k get crd <name> -o yaml` and read `spec.versions[0].schema.openAPIV3Schema.properties` first, that's the authoritative field list. Also check `spec.scope: Namespaced` vs `Cluster` to know if `-n` is needed.
