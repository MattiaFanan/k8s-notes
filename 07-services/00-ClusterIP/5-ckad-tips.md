# Services - ClusterIP - CKAD Exam Tips

## Exam Shortcuts
- `kubectl expose deployment <name> --port=80 --target-port=8080` is fastest scaffolding.
- Verify ready endpoints with `kubectl get endpoints <svc-name>`.

## Pitfalls
1. **Forgotten namespace**: Service and Pods must be in same namespace (or use fully qualified DNS).
2. **Selector/label mismatch**: Most common cause of empty endpoints.
3. **TargetPort vs Port**: `port` is Service port; `targetPort` is Pod container port.

## Time-Saver
```bash
alias k=kubectl

# Quick debug from inside cluster
k run tester --image=busybox --restart=Never --rm -it -- nslookup web-service
```
