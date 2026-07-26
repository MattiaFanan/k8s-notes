# NetworkPolicies - Imperative Commands

```bash
# Generate NetworkPolicy YAML with dry-run
kubectl create networkpolicy my-policy \
  --pod-selector app=database \
  --ingress \
  --from-pod-selector app=backend \
  --port 5432 \
  --dry-run=client -o yaml > netpol.yaml

# Apply explicit policy
kubectl apply -f netpol.yaml
```

## Verify Policy
```bash
# List policies in namespace
kubectl get networkpolicy -n <namespace>

# Describe policy details
kubectl describe networkpolicy <policy-name>
```

## Delete
```bash
kubectl delete networkpolicy <policy-name>
```
