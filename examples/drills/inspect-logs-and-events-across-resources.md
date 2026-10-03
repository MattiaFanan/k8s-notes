# Quickly inspect logs, events, and resource usage cluster-wide

**Task:** Find why deployment `payments` isn't progressing, and check recent cluster events plus resource usage.

**Fastest route:**
```bash
k get deploy payments                              # READY x/y, UP-TO-DATE, AVAILABLE columns
k rollout status deployment/payments --timeout=5s   # tells you exactly what's blocking
k get rs -l app=payments                            # which ReplicaSet is stuck
k get pods -l app=payments
k describe pod <stuck-pod>
k get events --sort-by=.lastTimestamp -A | tail -30  # cluster-wide, newest last
k top pods -l app=payments                          # needs metrics-server
k top nodes
```

**Multi-container log tip:**
```bash
k logs <pod> --all-containers=true
k logs <pod> -c <container> --since=10m
k logs -f deployment/payments                       # follows one pod from the deployment
```

**Gotcha:** `k get events` defaults to namespace-scoped and unsorted (creation order) — always add `--sort-by=.lastTimestamp` and check `-A` if the namespace isn't given. `k top` silently returns nothing if metrics-server isn't installed — don't waste time debugging the wrong thing.
