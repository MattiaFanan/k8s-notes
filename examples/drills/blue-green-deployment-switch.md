# Blue/green deployment cutover via service selector

**Task:** `app-blue` (v1) is live behind service `app-svc`. Deploy `app-green` (v2), verify it, then cut traffic over instantly.

**Fastest route:**
```bash
k create deployment app-green --image=myapp:2.0 --replicas=3 $do > app-green.yaml
```

Edit `app-green.yaml` — add `version: green` to `spec.template.metadata.labels`. Then apply and verify:
```bash
k apply -f app-green.yaml
k rollout status deployment/app-green
k port-forward deployment/app-green 8081:8080 &
curl localhost:8081/health

# cutover: repoint the existing service's selector
k patch svc app-svc -p '{"spec":{"selector":{"version":"green"}}}'
```

**Verify:**
```bash
k get svc app-svc -o jsonpath='{.spec.selector}'
k get endpoints app-svc     # IPs should now be app-green's pods
```

**Rollback (instant):**
```bash
k patch svc app-svc -p '{"spec":{"selector":{"version":"blue"}}}'
```

**Gotcha:** the whole trick is that a Service's `selector` is just a label match — cutover and rollback are single `kubectl patch` commands, no pod restarts needed. Make sure both `app-blue` and `app-green` deployments' pod templates carry a `version` label that the service can select on. `kubectl label deployment` only patches `metadata.labels` on the Deployment object itself, not `spec.template.metadata.labels` — generate YAML with `$do` and edit the pod template labels in place, or the Service won't select the pods.
