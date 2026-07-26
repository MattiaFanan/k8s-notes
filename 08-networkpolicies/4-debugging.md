# NetworkPolicies - Debugging

## Common Issues

1. **NetworkPolicy Appears to Do Nothing**
   - *Root Cause 1*: CNI plugin does not support NetworkPolicy (check with `kubectl get pods -n kube-system`).
   - *Root Cause 2*: Policy `podSelector` does not match the target Pod.
   - *Root Cause 3*: Missing Egress rule for DNS (UDP/TCP 53) -> Pods fail DNS resolution.

2. **Ingress Still Blocked**
   ```bash
   kubectl describe networkpolicy <name>
   kubectl get pod <pod-name> -o yaml
   ```
   - Verify `podSelector` matches target Pod labels.

3. **DNS Resolution Fails in Pod**
   ```bash
   kubectl exec -it <pod-name> -- nslookup kubernetes.default
   ```
   - Add egress rule for port 53 UDP/TCP to `kube-system` namespace.

## Diagnostic Checklist
```bash
kubectl get networkpolicy
kubectl get pod -o wide
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```
