# Security Contexts & Probes - Imperative Commands

```bash
# Generate basic Pod manifest with security defaults
kubectl run secure-app --image=nginx --dry-run=client -o yaml > pod.yaml

# Validate security context settings
kubectl get pod secure-app -o jsonpath='{.spec.securityContext}'
kubectl get pod secure-app -o jsonpath='{.spec.containers[0].securityContext}'
```

## ResourceQuota & LimitRange
```bash
# Create ResourceQuota
kubectl create quota quota --hard=pods=10,cpu=4,memory=8Gi

# Create LimitRange
kubectl create limitrange limits --default-cpu=100m --default-memory=128Mi

# Describe quota usage
kubectl describe resourcequota quota
```

## Quick Edits
```bash
# Patch security context
kubectl patch pod secure-pod --type='json' -p='[{"op": "replace", "path": "/spec/securityContext/runAsUser", "value":1001}]'
```
