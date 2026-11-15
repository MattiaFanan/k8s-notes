# 11 – ClusterRole, ClusterRoleBinding, groups, resourceNames

Run `./setup.sh` first. Namespace: `rbac-11` (contains Secrets `app-config` and `db-password`).

1. Create a ServiceAccount `monitor` in `rbac-11`.
2. Create a ClusterRole `node-viewer`: `get`, `list`, `watch` on nodes, and `get`, `list` on persistentvolumes.
3. Create a ClusterRoleBinding `node-viewer` that grants it to **both** the group `ops` and the SA `rbac-11/monitor`.
4. Create a Role `app-config-reader` in `rbac-11` that allows **only** `get` on the Secret named `app-config`
   (not `db-password`, no `list`). Bind it to `monitor` (RoleBinding `app-config-reader`).
5. Test with impersonation:
   ```bash
   kubectl get nodes --as=system:serviceaccount:rbac-11:monitor
   kubectl get secret app-config  -n rbac-11 --as=system:serviceaccount:rbac-11:monitor   # works
   kubectl get secret db-password -n rbac-11 --as=system:serviceaccount:rbac-11:monitor   # Forbidden
   kubectl get nodes --as=bob --as-group=ops                                              # works
   ```
6. Questions (answers in the solution):
   - Why can't you give `monitor` the right to *list* only `app-config` with `resourceNames`?
   - Could a Role (not a ClusterRole) grant access to nodes?

Check with `./verify.sh`, clean up with `./teardown.sh`.
