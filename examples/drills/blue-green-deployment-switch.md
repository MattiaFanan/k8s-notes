# Blue/green deployment cutover via service selector

**Task:** `app-blue` (v1) is live behind service `app-svc`. Deploy `app-green` (v2), verify it, then cut traffic over instantly.

**Fastest route:**
```bash
k create deployment app-green --image=myapp:2.0 --replicas=3
k label deployment app-green version=green
k rollout status deployment/app-green

# sanity-check green directly before cutover, bypassing the live service:
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

**Gotcha:** the whole trick is that a Service's `selector` is just a label match — cutover and rollback are single `kubectl patch` commands, no pod restarts needed. Make sure both `app-blue` and `app-green` deployments' pod templates carry a `version` label that the service can select on.
