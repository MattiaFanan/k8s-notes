# Namespace management: create, set default context, quota, and limit range

**Task:** Create namespace `team-a`, make it your default context namespace, cap it at 4 CPU / 8Gi memory total and 10 pods, and set a per-container default request/limit so pods without explicit resources still get one.

**Fastest route — create + switch context:**
```bash
k create namespace team-a
k config set-context --current --namespace=team-a   # stop typing -n team-a every command
k config view --minify | grep namespace              # confirm it stuck
```

**ResourceQuota (caps totals for the whole namespace):**
```bash
k create quota team-a-quota \
  --hard=cpu=4,memory=8Gi,pods=10 \
  -n team-a
```

**LimitRange (per-container defaults when a pod omits resources):** no imperative create — short YAML.
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: team-a-limits
  namespace: team-a
spec:
  limits:
  - type: Container
    default:
      cpu: 500m
      memory: 256Mi
    defaultRequest:
      cpu: 250m
      memory: 128Mi
    max:
      cpu: 1
      memory: 512Mi
```
```bash
k apply -f limitrange.yaml
```

**Verify:**
```bash
k get resourcequota team-a-quota -n team-a
k describe resourcequota team-a-quota -n team-a   # shows Used vs Hard
k get limitrange team-a-limits -n team-a
k run test --image=nginx -n team-a
k get pod test -n team-a -o jsonpath='{.spec.containers[0].resources}'   # picked up LimitRange defaults
```

**Gotcha:** a `ResourceQuota` with any `cpu`/`memory` hard limit forces every pod in that namespace to declare `resources.requests`/`limits` explicitly — pods without them get rejected (`FailedCreate`, "must specify limits/requests") unless a `LimitRange` supplies defaults, which is exactly why the two resources are paired in real clusters and in exam tasks. If a pod creation fails mysteriously in a namespace, check quota + limitrange before anything else:
```bash
k describe resourcequota -n team-a
k describe limitrange -n team-a
```
