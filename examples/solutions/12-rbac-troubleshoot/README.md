# 12 – Solution

## Diagnosis
```bash
A=--as=system:serviceaccount:rbac-12:ci-bot
kubectl auth can-i --list -n rbac-12 $A          # nothing useful: the binding does not reach ci-bot
kubectl describe rolebinding ci-deployer -n rbac-12   # subject ServiceAccount default/ci-bot
kubectl describe role ci-deployer -n rbac-12          # deployments in group "", resource "pod"
kubectl api-resources | grep -E '^(deployments|pods) ' # deployments -> apps/v1, pods -> v1 (core, "")
kubectl get pod ci-runner -n rbac-12 -o jsonpath='{.spec.serviceAccountName}'   # default
```
Bugs:
1. **RoleBinding subject** points to `ci-bot` in namespace `default`, a different (nonexistent) account.
   The SA namespace must be `rbac-12`.
2. **Wrong apiGroup**: deployments are in `apps`, not `""` (core). RBAC does not validate this, it just never matches.
3. **Missing verbs**: `watch`, `update`, `patch`.
4. **Scale** needs the subresource `deployments/scale` (`kubectl scale` uses it).
5. **`pod` instead of `pods`**: RBAC resources are the plural, lowercase names. `pods/log` is needed for `kubectl logs`.
6. The **pod** runs as `default`. `serviceAccountName` cannot be changed on a running pod, so recreate it:
   `kubectl replace --force -f pod.yaml` (or `kubectl get pod ci-runner -o yaml > p.yaml`, edit, delete, apply).

## Fix
```bash
kubectl apply -f rbac.yaml            # Role rules can be changed in place (kubectl edit role ... works too)
kubectl apply -f rolebinding.yaml     # subjects can be changed in place; only roleRef is immutable
kubectl replace --force --grace-period=0 -f pod.yaml
kubectl auth can-i --list -n rbac-12 --as=system:serviceaccount:rbac-12:ci-bot
```

## Key points
- RBAC is **additive only**: there is no "deny" rule. To forbid `delete`, don't grant it.
- RBAC accepts typos without complaint (wrong group, singular names, unknown verbs): always test with `kubectl auth can-i`.
- Find a resource's group and its real verbs: `kubectl api-resources -o wide | grep deployments`.
- In a Deployment you set `serviceAccountName` in `spec.template.spec`, and the rollout recreates the pods for you.
