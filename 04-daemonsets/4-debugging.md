# DaemonSets - Debugging

## Common Issues

1. **DaemonSet Pods Not Scheduled on Certain Nodes**
   ```bash
   kubectl describe daemonset node-logger
   kubectl get nodes -o wide
   ```
   *Root Cause*: Missing toleration for node taint, or nodeSelector mismatch.

2. **Multiple DaemonSet Pods on Same Node**
   - *Root Cause*: Selector mismatch causing duplicate controllers targeting same Pod labels. Fix: Ensure unique labels per DaemonSet.

3. **Rollout Stuck**
   ```bash
   kubectl rollout status daemonset node-logger
   kubectl describe daemonset node-logger
   ```
   - Check image pull errors, node conditions, or Pod scheduling failures.

## Diagnostic Commands
```bash
kubectl describe daemonset node-logger
kubectl get pods -l app=node-logger -o wide
kubectl get nodes --show-labels
kubectl get events --sort-by=.metadata.creationTimestamp
```
