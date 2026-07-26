# RBAC & ServiceAccounts - YAML Structure

Kubernetes uses Role-Based Access Control (RBAC) to manage permissions, and ServiceAccounts to provide identities for pods and processes. A Role grants permissions within a namespace, while a ClusterRole applies cluster-wide. RoleBindings and ClusterRoleBindings associate subjects (users, groups, or ServiceAccounts) with roles. The examples below show how to define ServiceAccounts, Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings.

## ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
automountServiceAccountToken: false
```

## Pod Using ServiceAccount

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: my-service-account
  automountServiceAccountToken: true
  containers:
  - name: app
    image: nginx:1.25
```

## Role & RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## ClusterRole & ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `automountServiceAccountToken` | Important | Yes | On ServiceAccount, set to `false` for least privilege; on Pod, set to `true` only if the pod needs to authenticate to the API server |
| `rules` | Required | Yes | On Role and ClusterRole; must include `apiGroups`, `resources`, and `verbs`. Use `apiGroups: [""]` for core resources (e.g., pods, secrets) |
| `subjects` | Required | Yes | On RoleBinding and ClusterRoleBinding; each entry has `kind` (ServiceAccount, User, Group), `name`, and `namespace` (for ServiceAccount) |
| `roleRef` | Required | Yes | On RoleBinding and ClusterRoleBinding; `roleRef.kind` must match the kind of the role being referenced (`Role` or `ClusterRole`) |
| `namespace` (metadata) | Required for Role/RoleBinding | Yes | Role and RoleBinding are namespace-scoped; omitting it defaults to `default` |
| `kind` (Role vs ClusterRole) | Important | Yes | Use `Role` + `RoleBinding` for namespace-scoped access; prefer this over ClusterRoleBinding when possible |
| `kind` (ClusterRole/ClusterRoleBinding) | Important | Yes | ClusterRole and ClusterRoleBinding are cluster-wide; use only when cluster-scoped access is needed |

**Best practice:** Prefer RoleBinding over ClusterRoleBinding when namespace-scoped access suffices.
