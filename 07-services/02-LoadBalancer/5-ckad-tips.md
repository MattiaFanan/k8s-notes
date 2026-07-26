# Services - LoadBalancer - CKAD Exam Tips

## Shortcuts
- `kubectl expose deployment <name> --type=LoadBalancer --port=80` works on supported clusters.
- Watch external IP: `kubectl get svc -w`.

## Pitfalls
1. **Pending external IP**: Not an error; CCM assigns IP asynchronously.
2. **Cloud-specific**: LoadBalancer depends on CCM integration.
3. **Bare metal**: LoadBalancer won't provision external IP without MetalLB or equivalent.

## Time-Saver
```bash
# Quick expose + watch
kubectl expose deploy web --port=80 --type=LoadBalancer
kubectl get svc web -w
```
