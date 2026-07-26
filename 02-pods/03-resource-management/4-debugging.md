# Resource Management - Debugging

## Common Issues

1. **Pod Stuck in Pending (Insufficient CPU/Memory)**
   ```bash
   kubectl describe pod <pod-name>
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```
   *Root Cause*: Node does not have enough allocatable resources to meet `requests`.

2. **OOMKilled (Exit Code 137)**
   ```bash
   kubectl get pod <pod-name>
   kubectl describe pod <pod-name> | grep -i oom
   ```
   *Root Cause*: Memory usage exceeds `limits.memory`.
   *Fix*: Increase memory limits or optimize application.

3. **ResourceQuota Exceeded**
   ```bash
   kubectl describe resourcequota ns-quota -n default
   kubectl get events -n default | grep Exceeded
   ```
   *Root Cause*: New resource would exceed hard quota.
   *Fix*: Scale down or increase quota.

4. **Throttling / Low Performance**
   ```bash
   kubectl top pod <pod-name>
   ```
   *Root Cause*: CPU usage near or above `limits.cpu` -> throttled.
   *Fix*: Increase CPU limits.

## Diagnostic Commands
```bash
kubectl top pod
kubectl top node
kubectl describe limitrange -n default
kubectl describe resourcequota -n default
```
