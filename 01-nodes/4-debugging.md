# Kubernetes Nodes - Debugging

## Common Issues

1. **Node NotReady**
   ```bash
    kubectl describe node node-1
    kubectl get events --sort-by=.metadata.creationTimestamp
    systemctl status kubelet
    ```
    *Root Causes*: kubelet down, CNI plugin down, network unreachable, disk pressure, PID pressure.

2. **Pod Stuck Pending (Unschedulable)**
   ```bash
   kubectl describe pod <pod-name>
   kubectl describe node node-1
   ```
   *Root Causes*: Insufficient resources, node tainted, nodeSelector/affinity not matched, Pod violates ResourceQuota.

3. **NodePressure Eviction**
   ```bash
   kubectl get nodes
   kubectl describe node node-1 | grep -i pressure
   ```
   *Root Cause*: MemoryPressure or DiskPressure triggered.
   *Fix*: Add resources, clean up disk, or add eviction thresholds.

## Diagnostic Commands
```bash
kubectl get nodes -o wide
kubectl get node -o jsonpath='{.items[*].status.conditions[*].type} {.items[*].status.conditions[*].status}'
kubectl top node
```
