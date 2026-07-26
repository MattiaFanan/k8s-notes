# Monitoring, Logging & API Deprecations - Debugging

## Common Issues

1. **Missing Metrics (`kubectl top` fails)**
   ```bash
   kubectl get deployment metrics-server -n kube-system
   kubectl top node
   ```
   *Root Cause*: metrics-server not deployed or not serving.

2. **Logs Empty**
   ```bash
   kubectl logs <pod-name>
   kubectl describe pod <pod-name>
   ```
   *Root Cause*: Application logs to file not stdout/stderr. Application crash may need complete Pod recreation.

3. **Pod Restarting but Logs Unhelpful**
   - Check previous container logs: `kubectl logs <pod> -p`.
   - Check `describe pod` events for `BackOff`.

4. **Deprecated API Warnings**
   ```bash
   kubectl get <resource> --all-namespaces
   ```
   *Root Cause*: Manifest uses old API group (`extensions/v1beta1`, `apps/v1beta1`).
   *Fix*: Update `apiVersion` and update schema fields.

## Diagnostic Checklist
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl top pod
```
