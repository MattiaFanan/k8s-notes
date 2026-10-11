# DaemonSets - Debugging

## Common Issues

1. **DaemonSet Pods Not Scheduled on Certain Nodes**
   ```bash
   kubectl describe daemonset node-logger
   kubectl get nodes -o wide
   ```
   *Root Cause*: Missing toleration for node taint, or nodeSelector mismatch.

2. **Multiple DaemonSet Pods on Same Node**

   A DaemonSet keeps exactly one Pod per matching node, and each Pod is owned by a single DaemonSet through `metadata.ownerReferences` — DaemonSets never share or adopt each other's Pods. If a node shows 2+ DaemonSet Pods, two controllers each created their own Pod on it.

   - *Root Cause*: overlapping selectors across different DaemonSets. A `selector` that does not match its own `template.metadata.labels` is rejected by the API, so the duplicate is not a mismatch inside one DaemonSet — it is two DaemonSets whose selectors both match the same nodes, each scheduling its own Pod set.
   - Example — both DaemonSets are valid on their own, but they overlap on `app: node-logger`, so every node gets 2 Pods (one per DaemonSet):
     ```yaml
     apiVersion: apps/v1
     kind: DaemonSet
     metadata:
       name: node-logger-old
     spec:
       selector:
         matchLabels:
           app: node-logger        # overlaps with node-logger-new
       template:
         metadata:
           labels:
             app: node-logger      # matches the selector, so the API accepts it
             version: old
         spec:
           containers:
           - name: logger
             image: fluentbit:1.9
     ---
     apiVersion: apps/v1
     kind: DaemonSet
     metadata:
       name: node-logger-new
     spec:
       selector:
         matchLabels:
           app: node-logger        # same overlap
       template:
         metadata:
           labels:
             app: node-logger
             version: new
         spec:
           containers:
           - name: logger
             image: fluentbit:2.0
     ```
   - *Fix*: give each DaemonSet a unique label/selector pair (e.g., `app: node-logger-old` vs `app: node-logger-new`) so the Pod sets are disjoint. `spec.selector` is immutable, so this needs delete + recreate, not `kubectl edit`.
   - *Other cause*: Pods orphaned with `kubectl delete daemonset <name> --cascade=orphan` keep running; a recreated DaemonSet with a different selector does not adopt them (only orphaned Pods matching its own selector are adopted), so old and new Pods coexist until the orphans are deleted manually.
   - *Rare*: a DaemonSet controller restart with a stale Pod cache can transiently create a duplicate Pod on a node; the next sync deletes it.

   ```bash
   # See duplicates per node
   kubectl get pods -l app=node-logger -o wide
   # Show which DaemonSet owns each Pod
   kubectl get pods -l app=node-logger -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.ownerReferences[0].name}{"\n"}{end}'
   ```

3. **Rollout Stuck**
   ```bash
   kubectl rollout status daemonset node-logger
   kubectl describe daemonset node-logger
   ```
   - Check image pull errors, node conditions, or Pod scheduling failures.

## Diagnostic Commands
```bash
kubectl describe daemonset node-logger
kubectl get pods -l app=node-logger -o wide
kubectl get nodes --show-labels
kubectl get events --sort-by=.metadata.creationTimestamp
```
