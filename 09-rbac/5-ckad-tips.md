# RBAC & ServiceAccounts - CKAD Exam Tips

## Shortcuts
- `kubectl create role` / `rolebinding` / `clusterrole` / `clusterrolebinding` syntax is verbose; prefer quick YAML templates.
- Use `kubectl auth can-i` to verify permissions instantly.

## Pitfalls
1. **Forgetting namespace in Role/RoleBinding**: Always include `-n <ns>`.
2. **Wrong ServiceAccount name**: Must reference existing SA exactly.
3. **Overusing ClusterRoleBinding instead of RoleBinding**: Prefer `RoleBinding` for namespace-scoped tasks.
4. **Missing `apiGroups`**: Use `""` for core resources (`pods`, `services`); use app group names (`apps`) for Deployments.

## Time-Saver
```bash
alias k=kubectl
# Validate SA access quickly
k auth can-i get pods -n default --as=system:serviceaccount:default:my-sa
```
