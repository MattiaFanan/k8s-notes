# Pods - Imperative Commands & Editability

## Fast Imperative Commands

```bash
# Generate basic Pod manifest
kubectl run nginx --image=nginx:1.25 --dry-run=client -o yaml > pod.yaml

# Create pod directly with custom command and environment variables
kubectl run custom-pod --image=busybox --env="KEY=VALUE" --restart=Never -- sh -c "sleep 3600"

# Expose container port imperatively
kubectl run redis --image=redis --port=6379

# Label & Annotate Pods
kubectl label pod nginx env=prod --overwrite
kubectl annotate pod nginx description="web front" --overwrite
```

## Editable vs Non-Editable Fields

When editing a running Pod (`kubectl edit pod <pod-name>` or `kubectl apply`):

### Editable Fields (In-Place)
- `spec.containers[*].image`
- `spec.initContainers[*].image`
- `spec.activeDeadlineSeconds`
- `spec.tolerations`

### Non-Editable Fields
- `spec.containers[*].name` (immutable structural identifier)
- `spec.volumes[*].name` (immutable structural identifier)

### Force Replace Strategy (CKAD Speed Trick)
To replace a Pod with updated non-editable fields:
```bash
kubectl replace --force -f pod.yaml
# OR
kubectl delete pod <pod-name> --force --grace-period=0
```
