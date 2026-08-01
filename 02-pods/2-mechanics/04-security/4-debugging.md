# Security Contexts & Probes - Debugging

## Common Issues

1. **CrashLoopBackOff from Privilege Issues**
   ```bash
   kubectl logs <pod-name>
   kubectl describe pod <pod-name> | grep -A4 Security
   ```
   *Root Cause*: Missing capabilities, `readOnlyRootFilesystem` blocking writes, or incorrect `runAsUser` permissions.

2. **Probe Failures Disrupt Traffic**
   ```bash
   kubectl describe pod <pod-name>
   ```
   - `Liveness probe failed`: Health check endpoint failing -> container restarted.
   - `Readiness probe failed`: Pod removed from service endpoints.

3. **ResourceQuota Exhausted**
   ```bash
   kubectl describe resourcequota quota
   kubectl get events
   ```
   *Root Cause*: Exceeded hard limit for pods, CPU, memory. Reduce workload size or update quota.

## Diagnostic Commands
```bash
# Security context validation
kubectl get pod -o yaml
kubectl auth can-i create pod --as=system:serviceaccount:default:my-sa

# Probe failure patterns
kubectl get events --sort-by=.metadata.creationTimestamp | grep probe
```
