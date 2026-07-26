# RBAC & ServiceAccounts - Debugging

## Common Issues

1. **Pod Cannot Access API**
   ```bash
   kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa
   ```
   *Root Cause*: Missing Role/ClusterRole or Binding; `serviceAccountName` not set.

2. **Forbidden Errors**
   ```bash
   kubectl describe rolebinding <binding-name>
   kubectl describe role <role-name>
   ```
   *Root Cause*: Role does not include required verbs/resources, or Binding references wrong Subject/Namespace.

3. **Default SA Too Restrictive**
   - Override with `spec.serviceAccountName`.
   - Never grant excess permissions (principle of least privilege).

4. **Automount Token Misuse**
   - Set `automountServiceAccountToken: false` for pods that do not need API access to reduce attack surface.

## Diagnostic Commands
```bash
# Check if SA can perform action
kubectl auth can-i create pods -n default --as=system:serviceaccount:default:my-sa
kubectl auth can-i '*' '*' --as=system:serviceaccount:default:my-sa
```
