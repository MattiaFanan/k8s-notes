# Resource Management - Imperative Commands

```bash
# Generate pod with resource requests/limits
kubectl run resource-demo --image=nginx --requests="cpu=100m,memory=128Mi" --limits="cpu=250m,memory=256Mi" --dry-run=client -o yaml > pod.yaml

# Apply LimitRange
kubectl apply -f limitrange.yaml

# Apply ResourceQuota
kubectl apply -f resourcequota.yaml

# View current quota usage
kubectl get resourcequota -n default
kubectl describe resourcequota ns-quota -n default
```

## Quick Scaling via Patching
```bash
# Scale replicas (must respect quota)
kubectl scale deployment my-dep --replicas=3

# Patch limits on existing container (editable: requests/limits)
kubectl patch pod resource-demo --type merge -p '{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"200m"}}}]}}'
```

## Cleanup
```bash
kubectl delete limitrange default-limits -n default
kubectl delete resourcequota ns-quota -n default
```
