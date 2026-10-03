# Init container that waits for a dependency before the main container starts

**Task:** Pod `web-app` should not start its main `nginx` container until a service `db-svc` is resolvable.

**Fastest route:**
```bash
k run web-app --image=nginx $do > pod.yaml
```
Add under `spec` (same indent level as `containers`):
```yaml
  initContainers:
  - name: wait-for-db
    image: busybox:1.28
    command: ['sh','-c','until nslookup db-svc; do echo waiting; sleep 2; done']
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k get pod web-app                      # STATUS: Init:0/1 until db-svc exists
k describe pod web-app | grep -A5 Init
k logs web-app -c wait-for-db
```

**Gotcha:** initContainers run sequentially to completion before ANY main container starts; they don't support `readinessProbe`. If asked for "retry until reachable," `until <cmd>; do sleep; done` is the fastest pattern — no need for a real health-check tool.
