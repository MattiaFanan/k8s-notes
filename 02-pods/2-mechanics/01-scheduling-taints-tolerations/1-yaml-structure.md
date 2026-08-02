# Pods - Taints & Tolerations - YAML Structure

Taints and tolerations work together to control which pods can be scheduled onto which nodes. A **taint** is applied to a node to repel pods that do not have a matching toleration, while a **toleration** is added to a pod to allow it to be scheduled on nodes with matching taints. This mechanism is useful for reserving nodes for specific workloads, such as dedicating a node to a special project or keeping sensitive workloads isolated. Taints also support the `NoExecute` effect, which evicts already-running pods that lack a toleration, and `tolerationSeconds` can be used to delay that eviction.

## Node with Taint

```bash
# Imperative taint
kubectl taint nodes node1 key=value:NoSchedule
```

## Pod with Toleration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
  tolerations:
  - key: key
    operator: "Equal"
    value: "value"
    effect: NoSchedule
  - key: key
    operator: "Exists"
    effect: NoExecute
    tolerationSeconds: 3600
```

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `key` | Conditional | Required unless operator is `Exists`. |
| `operator` | No | `Equal` (default) or `Exists`. |
| `value` | Conditional | Required when operator is `Equal`. |
| `effect` | Yes | `NoSchedule`, `PreferNoSchedule`, `NoExecute`, `NoExecute` (with `tolerationSeconds`). |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `key` (taint) | Required | No — use `kubectl taint` | Must follow `key=value:effect` format. Remove with `key:effect-` (no value). |
| `value` (taint) | Optional | No — use `kubectl taint` | Omit when using `Exists` operator. |
| `operator` (taint) | Optional | No — use `kubectl taint` | Defaults to `Equal`. Use `Exists` to taint all nodes regardless of value. |
| `effect` (taint) | Required | No — use `kubectl taint` | One of `NoSchedule`, `PreferNoSchedule`, `NoExecute`. |
| `key` (toleration) | Conditional | Yes — edit pod spec | Required unless `operator` is `Exists`. |
| `operator` (toleration) | Optional | Yes — edit pod spec | Defaults to `Equal`. Use `Exists` to tolerate any taint with the matching key/effect. |
| `value` (toleration) | Conditional | Yes — edit pod spec | Required when `operator` is `Equal`; must match the taint value exactly. |
| `effect` (toleration) | Important | Yes — edit pod spec | Must match the taint effect (`NoSchedule`, `PreferNoSchedule`, `NoExecute`). |
| `tolerationSeconds` | Important | Yes — edit pod spec | Only valid with `NoExecute`. Defines how long a pod stays bound before eviction. |
| Node taint | — | No — use `kubectl taint` | Manage via `kubectl taint nodes <node> ...` and `kubectl taint nodes <node> -`. |
| Pod tolerations | — | Yes — `kubectl edit pod <name>` | Declared in `spec.tolerations` of the pod YAML.
