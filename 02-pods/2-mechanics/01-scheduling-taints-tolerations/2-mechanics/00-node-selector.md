# Pods - Scheduling - Node Selector

## Overview

`nodeSelector` is the simplest form of pod scheduling constraint in Kubernetes. It allows you to constrain pods to run on nodes with specific labels. When a pod has a `nodeSelector`, the scheduler will only place it on nodes that have all the labels specified in the selector.

### How nodeSelector Works

The `nodeSelector` field is a map of key-value pairs. The scheduler looks for nodes that have labels matching all key-value pairs in the `nodeSelector`. If no node matches, the pod remains in `Pending`.

```yaml
spec:
  nodeSelector:
    kubernetes.io/os: linux
    node-role.kubernetes.io/worker: ""
```

This pod will only be scheduled on nodes that have both labels:
- `kubernetes.io/os=linux`
- `node-role.kubernetes.io/worker=""` (empty value means the label exists with any value, or no value)

### Key Characteristics

1. **Simple and fast**: `nodeSelector` uses exact key-value matching. It does not support set-based operations (In, NotIn, Exists, DoesNotExist). For set-based matching, use `nodeAffinity`.

2. **Hard constraint**: If no node matches the `nodeSelector`, the pod will never be scheduled. This is a hard requirement, not a preference.

3. **Combines with other scheduling constraints**: `nodeSelector` works together with `tolerations`, `affinity`, and `nodeName`.

### Example: Schedule on Linux Nodes Only

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: linux-only-pod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - name: app
    image: nginx:1.25
```

### Example: Schedule on Worker Nodes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: worker-pod
spec:
  nodeSelector:
    node-role.kubernetes.io/worker: ""
  containers:
  - name: app
    image: nginx:1.25
```

## nodeSelector vs nodeAffinity

`nodeSelector` is limited to exact key-value matching. `nodeAffinity` provides more expressive set-based matching and supports both required and preferred constraints.

| Feature | nodeSelector | nodeAffinity |
|---------|-------------|--------------|
| Matching | Exact key=value | Set-based (In, NotIn, Exists, DoesNotExist) |
| Constraint type | Hard only | Hard (`required`) and soft (`preferred`) |
| Logical operators | AND only | AND/OR with matchExpressions |
| Multiple values | No | Yes (via matchExpressions) |

### When to Use nodeSelector

Use `nodeSelector` when:
- You need a simple, hard constraint based on node labels
- The label values are known and stable
- You don't need set-based matching or soft constraints

Use `nodeAffinity` when:
- You need set-based matching (e.g., "schedule on nodes with zone in (us-east-1a, us-east-1b)")
- You need soft constraints (preferred scheduling)
- You need complex logical expressions

## nodeName

`nodeName` is the most direct way to schedule a pod on a specific node. It bypasses the scheduler entirely and places the pod on the named node.

```yaml
spec:
  nodeName: worker-node-1
  containers:
  - name: app
    image: nginx:1.25
```

### Key Characteristics of nodeName

1. **Bypasses the scheduler**: The pod is placed directly on the named node without going through the scheduling queue.

2. **Hard constraint**: If the named node does not exist or is not ready, the pod remains in `Pending` indefinitely.

3. **No automatic rescheduling**: If the node goes down, the pod is NOT automatically rescheduled to another node. It remains on the original node (or in `Pending` if the node is gone).

4. **Ignores taints and tolerations**: `nodeName` does not respect node taints. The pod will be placed on the node even if it has taints that would normally prevent scheduling.

### When to Use nodeName

- **Testing and debugging**: Quickly place a pod on a specific node for troubleshooting.
- **Node-specific workloads**: When a workload must run on a specific node (e.g., for hardware access, local data).
- **Avoid for production**: `nodeName` is brittle. If the node fails, the pod is stuck. Use `nodeSelector` or `nodeAffinity` for production workloads.

## Combining nodeSelector with Taints and Tolerations

`nodeSelector` and `tolerations` work together to provide fine-grained scheduling control:

- `nodeSelector` selects nodes with specific labels.
- `tolerations` allow the pod to run on nodes with matching taints.

```yaml
spec:
  nodeSelector:
    kubernetes.io/os: linux
    node-role.kubernetes.io/worker: ""
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx:1.25
```

This pod will be scheduled on nodes that:
1. Have the labels `kubernetes.io/os=linux` and `node-role.kubernetes.io/worker=""`
2. Are NOT tainted with `NoSchedule` (unless the toleration matches)

## Inspecting Node Labels

```bash
# List all nodes with their labels
kubectl get nodes --show-labels

# Get labels for a specific node
kubectl get node <node-name> --show-labels

# Check if a node has a specific label
kubectl get node <node-name> -o jsonpath='{.metadata.labels.kubernetes\.io/os}'

# Filter nodes by label
kubectl get nodes -l kubernetes.io/os=linux
kubectl get nodes -l node-role.kubernetes.io/worker
```

## Common Pitfalls

1. **Using a label that no node has**: If the `nodeSelector` specifies a label that no node has, the pod will be stuck in `Pending` forever. Always verify node labels before using them in a `nodeSelector`.

2. **Confusing nodeSelector with pod labels**: `nodeSelector` matches **node labels**, not pod labels. This is a common source of confusion.

3. **Using nodeName for production**: `nodeName` is brittle and does not support automatic rescheduling. Prefer `nodeSelector` or `nodeAffinity` instead.

4. **Forgetting that nodeSelector is a hard constraint**: Unlike `preferredDuringSchedulingIgnoredDuringExecution` in node affinity, `nodeSelector` has no fallback. If no node matches, the pod is never scheduled.

5. **Label changes don't affect running pods**: Changing node labels does not trigger rescheduling of already-running pods. You must delete and recreate the pod for the new `nodeSelector` to take effect.

## Exam Tips

- If a CKAD question asks you to "schedule a pod on nodes with a specific label", use `nodeSelector` in the pod spec.
- If the question asks for a "preferred" scheduling constraint, use `nodeAffinity` with `preferredDuringSchedulingIgnoredDuringExecution`.
- Always verify node labels with `kubectl get nodes --show-labels` before writing a `nodeSelector`.
- Use `kubectl describe pod <name>` to see scheduling decisions and events when a pod is stuck in `Pending`.

## See also

- [Taints and Tolerations - Core Concepts](../01-scheduling-taints-tolerations/2-mechanics/02-core-concepts.md)
- [Taints and Tolerations - Toleration Logic](../01-scheduling-taints-tolerations/2-mechanics/04-toleration-logic.md)
- [Scheduling Affinity - Core Concepts](../02-scheduling-affinity/2-mechanics/02-core-concepts.md)
- [Pods - YAML Structure](../../02-pods/1-yaml-structure.md)
