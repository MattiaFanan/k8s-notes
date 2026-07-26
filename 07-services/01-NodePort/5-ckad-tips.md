# Services - NodePort - CKAD Exam Tips

## Shortcuts
- Let `kubectl expose` auto-assign NodePort, then read it from `kubectl get svc`.
- Use `curl` or `wget` from a test Pod to verify.

## Pitfalls
1. **Cloud provider firewall/NSG**: External access may be blocked outside cluster.
2. **Missing node selector/tolerations**: Backend Pods may not be on all nodes for `Local` traffic.
3. **Port already in use**: Auto-assignment avoids conflicts.

## Time-Saver
```bash
# Auto NodePort + quick verify
kubectl expose deploy web --port=80 --type=NodePort
kubectl get svc web
```
