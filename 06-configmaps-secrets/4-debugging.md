# ConfigMaps & Secrets - Debugging

## Common Failure Modes

1. **ConfigMap/Secret Not Found by Pod**
   ```bash
   kubectl describe pod <pod-name>
   kubectl get configmap <name> -o yaml
   ```
   *Root Cause*: Key reference typo in `configMapKeyRef` / `secretKeyRef`, or wrong ConfigMap/Secret name.

2. **`CreateContainerConfigError`**
   - Error: `Error: configmap "app-config" not found`.
   - Fix: Create referenced ConfigMap/Secret before Pod, or ensure correct namespace.

3. **Invalid Base64 Secret**
   - Secret values must be base64 encoded if defined in YAML `data` (use `stringData` for plain text).
   - Verify with: `echo -n "value" | base64`

## Diagnostic Commands

```bash
# List all ConfigMaps/Secrets in namespace
kubectl get configmap,secret

# Inspect exact keys
kubectl get configmap app-config -o jsonpath='{.data}'
kubectl get secret db-credentials -o jsonpath='{.data}'
```
