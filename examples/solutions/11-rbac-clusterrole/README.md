# 11 – Solution

Imperative:
```bash
kubectl create sa monitor -n rbac-11
kubectl create clusterrole node-viewer --verb=get,list,watch --resource=nodes
kubectl edit clusterrole node-viewer        # add the persistentvolumes rule (get, list); or apply rbac.yaml
kubectl create clusterrolebinding node-viewer --clusterrole=node-viewer --group=ops --serviceaccount=rbac-11:monitor
kubectl create role app-config-reader -n rbac-11 --verb=get --resource=secrets --resource-name=app-config
kubectl create rolebinding app-config-reader -n rbac-11 --role=app-config-reader --serviceaccount=rbac-11:monitor
```
Test: `kubectl auth can-i --list --as=system:serviceaccount:rbac-11:monitor -n rbac-11`.

## Key points
| object | scope | grants |
|--------|-------|--------|
| Role + RoleBinding | namespace | namespaced resources in that namespace |
| ClusterRole + RoleBinding | namespace | the ClusterRole's namespaced rules, in that namespace only |
| ClusterRole + ClusterRoleBinding | cluster | everything in the role, in all namespaces + cluster-scoped resources |

- One binding can have many subjects: users, groups, service accounts. `--group`, `--user` and `--serviceaccount` can be repeated.
- `roleRef` is **immutable**. To point a binding at another role, delete and recreate the binding.
- `kubectl api-resources --namespaced=false` lists cluster-scoped resources (nodes, persistentvolumes,
  storageclasses, ingressclasses, namespaces, clusterroles...).
- Impersonation: `--as=<user>` plus optional `--as-group=<group>` (needs `--as`). For an SA: `--as=system:serviceaccount:<ns>:<name>`.

## Answers
- `resourceNames` only works for requests that name **one** object (`get`, `update`, `patch`, `delete`).
  `list`, `watch` (without a field selector on the name) and `create` have no object name when the request is authorized,
  so a rule with `resourceNames` never matches them. That is why `monitor` gets `get` on `app-config` but cannot `list` secrets.
- No. Nodes are cluster-scoped. A Role is namespaced and can only grant namespaced resources,
  so cluster-scoped resources need a ClusterRole **and** a ClusterRoleBinding.
