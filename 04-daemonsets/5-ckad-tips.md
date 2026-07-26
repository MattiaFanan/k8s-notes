# DaemonSets - CKAD Exam Tips

## Shortcuts
- Use `kubectl create daemonset ... --dry-run=client -o yaml > ds.yaml` for quick scaffolding.
- Validate with `kubectl get pods -l app=node-logger -o wide`.

## Pitfalls
1. **Forgetting tolerations for control-plane nodes**: DaemonSet Pods fail to schedule on tainted master nodes without toleration.
2. **Label collisions**: Ensure DaemonSet `selector` matches `template.metadata.labels` exactly.
3. **Namespace restriction**: DaemonSet respects namespace scoping just like other controllers.

## Time-Saver
```bash
alias k=kubectl

# Quick DaemonSet creation
k create ds node-logger --image=fluentbit $do > ds.yaml
k apply -f ds.yaml
k get pods -l app=node-logger -o wide
```
