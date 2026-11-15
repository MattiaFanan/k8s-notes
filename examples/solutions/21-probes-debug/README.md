# 21 – Solution

## 1. Probes
```bash
kubectl describe pod -n probe-21 -l app=shop | grep -A2 -E 'Liveness|Readiness|Unhealthy'
#   Readiness probe failed: dial tcp ...:8080: connect: connection refused   (nginx listens on 80)
#   Liveness probe failed: HTTP probe failed with statuscode: 404            (/healthz does not exist)
kubectl edit deploy shop -n probe-21           # or: kubectl patch deploy shop -n probe-21 --patch-file probes-patch.yaml
kubectl rollout status deploy/shop -n probe-21
```
A probe has exactly **one** handler (`httpGet`, `tcpSocket`, `exec` or `grpc`). With `kubectl edit`, replace `tcpSocket`.
In a strategic merge patch you must remove it explicitly (`tcpSocket: null`).

## 2. crasher
```bash
kubectl get pod crasher -n probe-21             # CrashLoopBackOff, RESTARTS > 0
kubectl logs crasher -n probe-21 --previous     # logs of the instance that crashed
kubectl logs crasher -n probe-21 --previous | grep FATAL > work/crasher.txt
kubectl describe pod crasher -n probe-21        # Last State: Terminated, Reason: Error, Exit Code: 1
```
`--previous` means "the instance before the current one". While the pod waits in back-off, the *current* instance is the
crashed one, so plain `kubectl logs crasher` shows the error, and `--previous` may say "unable to retrieve container logs"
(the older instance was already cleaned up). Once it is running again, `--previous` shows the crash.

## 3. Ephemeral container
```bash
kubectl debug -it -n probe-21 app --image=busybox:1.36 --container=debugger --target=app -- sh
/ # ps aux           # PID 1 is /pause: with --target you share app's process namespace
```
- Ephemeral containers are added to a running pod through the `ephemeralcontainers` subresource. They cannot be removed afterwards
  and have no ports or probes. Good for distroless images.
- `kubectl debug <pod> --copy-to=app-copy --share-processes --image=...` makes a copy of the pod instead.
  `kubectl debug node/<node> -it --image=busybox` gives a shell on the node, with its filesystem under `/host`.

## 4. Answer
| probe | on failure | used for |
|-------|-----------|----------|
| readiness | pod is removed from Service endpoints, **not restarted** | temporary unavailability, warm-up |
| liveness | container is **killed and restarted** | deadlocks, hung processes |
| startup | while it runs, liveness/readiness are paused; failing it restarts the container | slow-starting apps |
A liveness probe that is too strict (here: wrong path, `failureThreshold: 1`) causes endless restarts. Never point liveness at a dependency like a database.
