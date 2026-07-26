# Admission Control, Authentication & Authorization - Debugging

## Common Issues

1. **Admission Webhook Not Called**
   ```bash
   kubectl describe validatingwebhookconfiguration object-validator
   kubectl get events -n default
   ```
   *Root Cause*: Wrong `apiGroups`, missing `operations`, `caBundle` mismatch, or service port/path misconfigured.

2. **Pod Creation Fails with 403 Forbidden**
   *Root Cause*: RBAC binding missing, SA not authorized, or webhook rejecting creation.

3. **Private Image Pull Failure**
   - *Root Cause*: `imagePullSecrets` missing or incorrect registry credentials.
   - *Fix*: Verify Secret exists and is attached to SA/Pod.

4. **Token Expiry**
   - ServiceAccount tokens expire (v1.24+ projected volume token bound to projected volume or creation timestamp).

## Diagnostic Commands
```bash
# Check SA token Secret binding
kubectl get sa default -o yaml
kubectl describe secret <token-secret-name>

# Check webhook config details
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Inspect pod security admission (psa)
kubectl get namespace default -o yaml
kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.pod-security\.kubernetes\.io/enforce}{"\n"}{end}'
```
