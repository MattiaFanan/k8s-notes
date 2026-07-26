# Declarative vs Imperative - Debugging

## Declarative Issues

1. **`kubectl apply` Fails with Conflict**
   ```bash
   kubectl apply -f manifest.yaml
   # Error: ApplyConflictError
   ```
   *Root Cause*: Object was modified since last apply (field ownership conflict).
   *Fix*: Use `--force-conflicts` or re-apply updated manifest reflecting current state.

2. **Drift from Expected State**
   ```bash
   kubectl diff -f manifest.yaml
   kubectl get deployment nginx -o yaml > live.yaml
   diff manifest.yaml live.yaml
   ```
   *Root Cause*: Someone applied changes imperatively, or controller modified object.
   *Fix*: Reconcile with `kubectl apply -f manifest.yaml` or GitOps sync.

3. **Orphaned Objects**
   - Declarative does not automatically delete resources removed from manifest (use `--prune` with `kubectl apply -f dir/`).

## Imperative Issues

1. **`kubectl create` Fails Because Object Exists**
   ```bash
   kubectl create deployment nginx --image=nginx:1.25
   # Error: deployment.apps "nginx" already exists
   ```
   *Fix*: Use `kubectl replace --force -f` or switch to declarative.

2. **Imperative Changes Not Reproducible**
   - Hard to reconstruct exact cluster state from imperative history.
   - Fix: Always commit declarative manifests to Git.

## Best Practice Debugging
```bash
# What does the cluster think the state is?
kubectl get all
kubectl get deployment nginx -o yaml

# Does the manifest match?
kubectl diff -f manifest.yaml

# Who owns what fields (server-side apply)?
kubectl get deployment nginx -o jsonpath='{.metadata.annotations}'
```
