# DaemonSets - YAML Structure

A DaemonSet ensures that a copy of a pod runs on every eligible node in the cluster, or on a subset of nodes selected by node selectors or taints. It is commonly used for cluster-wide daemons such as log collectors, monitoring agents, and network plugins. When new nodes join the cluster, the DaemonSet automatically schedules pods on them.

## Basic DaemonSet Manifest

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-logger
spec:
  selector:
    matchLabels:
      app: node-logger
  template:
    metadata:
      labels:
        app: node-logger
    spec:
      containers:
      - name: logger
        image: fluentbit:latest
```

## DaemonSet with Node Selector / Taints

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: exporter
        image: prom/node-exporter:latest
      nodeSelector:
        node-role.kubernetes.io/worker: ""
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
 ```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `spec.selector` | Required | No (immutable) | Must match `template.metadata.labels`. Immutable after creation to prevent overlapping DaemonSets. |
| `spec.template` | Required | Yes (partial) | Pod spec; same structure as a Pod spec. `template.metadata.labels` must match `spec.selector.matchLabels`. |
| `spec.template.spec.containers` | Required | Yes | Standard container spec. |
| `spec.updateStrategy.type` | Optional | Yes | `RollingUpdate` (default) or `OnDelete`. |
| `spec.updateStrategy.rollingUpdate.maxUnavailable` | Optional | Yes | Used with `RollingUpdate`. Controls how many pods can be unavailable during an update. |
| `spec.updateStrategy.rollingUpdate.maxSurge` | Optional | Yes | Used with `RollingUpdate`. Controls how many pods can be created above the desired count during an update. |
| `spec.template.spec.nodeSelector` | Optional | Yes | Targets specific nodes for pod scheduling. |
| `spec.template.spec.tolerations` | Optional | Yes | Allows pods to be scheduled on nodes with taints (e.g., control plane nodes). |
| `updateStrategy` rolling update fields | Optional | Yes | Fields under `rollingUpdate` are editable via `kubectl edit`. |
| — | — | — | One pod per node by default. The DaemonSet controller runs on the control plane. |
