# Storage - Debugging

## Common Issues

1. **PVC Remains Pending**
   ```bash
   kubectl describe pvc my-pvc
   kubectl get events
   ```
   *Root Causes*: No matching PV, StorageClass provisioner failure, `VolumeBindingMode` blocking immediate binding, or insufficient cluster resources.

2. **Pod Stuck in ContainerCreating**
   ```bash
   kubectl describe pod <pod-name>
   kubectl get pvc
   ```
   *Root Causes*: PVC not bound, hostPath path missing on node.

3. **ReadWriteOnce Volume Attached to Multiple Nodes**
   - *Root Cause*: Pod scheduled on multiple nodes concurrently (DaemonSet without spread constraints).
   - *Fix*: Define `accessModes` correctly or use `ReadWriteMany`.

4. **Data Loss on Pod Delete**
   - `emptyDir` volumes are deleted when Pod is removed.
   - Fix: Use PV/PVC or StatefulSets with volumeClaimTemplates.
