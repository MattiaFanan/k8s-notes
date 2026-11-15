# 24 – Solution

```bash
kubectl apply -f web.yaml
kubectl get pod waiter -n multi-24              # Init:0/1
kubectl logs waiter -n multi-24 -c wait-for-backend    # "waiting" ... NXDOMAIN
kubectl create service clusterip backend -n multi-24 --tcp=80:80   # the name now resolves, init finishes
kubectl exec -n multi-24 web -c nginx -- wget -qO- 127.0.0.1
kubectl logs -n multi-24 web -c log-shipper     # 127.0.0.1 - - [...] "GET / HTTP/1.1" 200 ...
kubectl get job batch -n multi-24               # Complete
```

## Key points
- **Init containers** run one after another, each must exit 0 before the next starts, and the app containers start only
  after all of them. A failing init container is retried according to the pod's `restartPolicy`. The status shows as `Init:N/M` / `Init:Error`.
- **Native sidecar** (stable since 1.33) = an `initContainers` entry with `restartPolicy: Always`. It starts **before** the app
  containers (and can have a startup/readiness probe they wait for), runs for the whole pod lifetime, and is stopped
  **after** the app containers. Use `-c <name>` for logs/exec in multi-container pods.
- Containers in a pod share the network namespace (`127.0.0.1`) and the volumes you mount in both. `emptyDir` is the usual way to share files.
- Patterns: **sidecar** (log shipping, proxy), **ambassador** (a local proxy to an outside service), **adapter** (converts the app's
  output, for example metrics format).

## Answer
A Job is complete when **all** regular containers of its pod have exited. A sidecar in `containers:` running `sleep 3600`
(or a log shipper that never exits) keeps the pod Running, so the Job never completes. Native sidecars are
not counted and are stopped automatically when the main containers finish.
