# Pods - Taints & Tolerations - Debugging

## Common Issues

1. **Pod Stuck Pending / Unschedulable**
   ```bash
   kubectl describe pod <pod-name>
   kubectl describe node <node-name>
   ```
   *Root Cause*: Node has taint effect `NoSchedule` or `NoExecute`, and Pod lacks matching toleration.

2. **Pod Evicted Unexpectedly**
   ```bash
   kubectl get pods
   kubectl describe node <node-name>
   ```
   *Root Cause*: `NoExecute` taint applied (e.g., node unreachable, disk pressure) and Pod does not tolerate it.

3. **Master Nodes Unused by Default**
   - Modern K8s: control-plane nodes have `node-role.kubernetes.io/control-plane:NoSchedule`.
   - Add toleration to schedule Pods there (rare/not recommended in production).

## Diagnostic Commands
```bash
kubectl describe node <node-name> | grep -i taint
kubectl get events --sort-by=.metadata.creationTimestamp
```
