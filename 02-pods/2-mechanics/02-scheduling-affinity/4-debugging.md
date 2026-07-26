# Pods - Scheduling Affinity - Debugging

## Common Issues

1. **Pod Stuck Pending with Node Affinity**
   ```bash
   kubectl describe pod <pod-name>
   kubectl get nodes -L <label-key>
   ```
   *Root Cause*: No node satisfies `requiredDuringSchedulingIgnoredDuringExecution`.

2. **Pod Not Co-located**
   - Verify node labels and target Pod labels match `podAffinity` selector.
   - Verify topology key (`kubernetes.io/hostname`) exists on nodes.

3. **Anti-Affinity Not Working**
   ```bash
   kubectl get pods -o wide
   kubectl describe node <node-name>
   ```
   *Root Cause*: Pods do not match labelSelector, or topologyKey missing/is incorrect.

## Diagnostic Commands
```bash
kubectl describe pod <pod-name> | grep -A20 Affinity
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get events --sort-by=.metadata.creationTimestamp
```
