# Create a deployment, scale it, and expose it as a service

**Task:** Create a deployment named `web` running `nginx:1.25` with 3 replicas, then expose it on port 80 via a ClusterIP service named `web-svc`.

**Fastest route:**
```bash
k create deployment web --image=nginx:1.25 --replicas=3
k expose deployment web --name=web-svc --port=80 --target-port=80
```

**Verify:**
```bash
k get deploy web -o wide
k get svc web-svc
k get endpoints web-svc   # should list 3 pod IPs
```

**Gotcha:** `--replicas` on `create deployment` works directly (no need for a separate `scale` call). If replicas were requested after the fact: `k scale deploy web --replicas=5`.
