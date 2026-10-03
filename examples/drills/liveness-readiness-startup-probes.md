# Add liveness, readiness, and startup probes to a pod

**Task:** Pod `probed` (nginx) needs: readiness probe on HTTP GET `/` port 80, liveness probe via `cat /tmp/healthy`, startup probe allowing 30s to boot.

**Fastest route:**
```bash
k run probed --image=nginx $do > pod.yaml
```
Edit container block:
```yaml
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    livenessProbe:
      exec:
        command: ["cat", "/tmp/healthy"]
      periodSeconds: 5
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 6      # 6 * periodSeconds(default 10s) = 60s... tune below
      periodSeconds: 5         # 6*5=30s window
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k describe pod probed | grep -A3 -i probe
k get pod probed -w   # watch READY flip 0/1 -> 1/1
```

**Gotcha:** while `startupProbe` runs, liveness/readiness are disabled — this is the fix for slow-boot apps getting killed by liveness before they're ready. Exam often frames this as "app takes X seconds to start, don't let it get killed."
