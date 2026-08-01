# DaemonSets - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- Use `kubectl create daemonset ... --dry-run=client -o yaml > ds.yaml` for quick scaffolding.
- Validate with `kubectl get pods -l app=node-logger -o wide`.

## Pitfalls
1. **Forgetting tolerations for control-plane nodes**: DaemonSet Pods fail to schedule on tainted master nodes without toleration.
2. **Label collisions**: Ensure DaemonSet `selector` matches `template.metadata.labels` exactly.
3. **Namespace restriction**: DaemonSet respects namespace scoping just like other controllers.
4. **DaemonSet Pods cannot use `restartPolicy: Never`**: DaemonSet-managed pods must use `Always`.
5. **Updating DaemonSet strategy**: `RollingUpdate` is the only strategy for DaemonSets.

## Time-Saver
```bash
alias k=kubectl

# Quick DaemonSet creation
k create ds node-logger --image=fluentbit $do > ds.yaml
k apply -f ds.yaml
k get pods -l app=node-logger -o wide

# Rollback DaemonSet
k rollout undo daemonset/node-logger
```

## See also

- [DaemonSet YAML Structure](1-yaml-structure.md)
- [DaemonSet Core Behavior](2-mechanics/01-core-behavior.md)
- [DaemonSet Update Behavior](2-mechanics/04-update-behavior.md)
