# RBAC & ServiceAccounts - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- `kubectl create role` / `rolebinding` / `clusterrole` / `clusterrolebinding` syntax is verbose; prefer quick YAML templates.
- Use `kubectl auth can-i` to verify permissions instantly.
- Use `kubectl auth can-i --list` to audit all permissions for a subject.

## Pitfalls
1. **Forgetting namespace in Role/RoleBinding**: Always include `-n <ns>`.
2. **Wrong ServiceAccount name**: Must reference existing SA exactly.
3. **Overusing ClusterRoleBinding instead of RoleBinding**: Prefer `RoleBinding` for namespace-scoped tasks.
4. **Missing `apiGroups`**: Use `""` for core resources (`pods`, `services`); use app group names (`apps`) for Deployments.
5. **Subject kind mismatch**: The `subjects[].kind` field must be `User`, `Group`, or `ServiceAccount`. Using the wrong kind creates a binding that grants no permissions.
6. **ServiceAccount namespace mismatch**: The `namespace` field in `subjects` must match the ServiceAccount's namespace.

## Time-Saver
```bash
alias k=kubectl
# Validate SA access quickly
k auth can-i get pods -n default --as=system:serviceaccount:default:my-sa

# Audit all permissions for a user
k auth can-i --list --as=dev-user -n production
```

## See also

- [RBAC YAML Structure](1-yaml-structure.md)
- [RBAC Core Components](2-mechanics/03-core-components.md)
- [RBAC Common Exam Patterns](2-mechanics/02-common-exam-patterns.md)
- [Admission Control](../../13-admission-control/2-mechanics/01-admission-controllers.md)
