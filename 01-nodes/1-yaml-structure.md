# Kubernetes Nodes - YAML Structure

A Node represents a worker machine in the Kubernetes cluster—either physical or virtual—where pods are scheduled and run. The kubelet on each node registers the node with the control plane, reports its capacity and conditions, and manages pod lifecycles. Node objects are typically read-only and managed by the cluster, but their labels, taints, and capacity fields are essential for scheduling and resource allocation.

## Node Object (Read-Only)

```yaml
apiVersion: v1
kind: Node
metadata:
  name: node-1
  labels:
    node-role.kubernetes.io/worker: ""
    topology.kubernetes.io/zone: us-east-1a
    topology.kubernetes.io/region: us-east-1
spec:
  taints:
  - key: node-role.kubernetes.io/control-plane
    effect: NoSchedule
status:
  capacity:
    cpu: "4"
    memory: 16Gi
    pods: "110"
  allocatable:
    cpu: "3900m"
    memory: 15Gi
    pods: "110"
  conditions:
  - type: Ready
    status: "True"
    lastHeartbeatTime: "2026-07-26T14:00:00Z"
```

## Key Fields

| Field | Notes |
| :--- | :--- |
| `metadata.name` | Hostname or override from kubelet `--hostname-override`. |
| `metadata.labels` | Used for nodeSelector, affinity, topology. |
| `spec.taints` | Repels Pods without matching tolerations. |
| `status.capacity` | Total node resources. |
| `status.allocatable` | Resources available to Pods after system reserved. |
| `status.conditions` | Ready, MemoryPressure, DiskPressure, PIDPressure, NetworkUnavailable. |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `metadata.name` | Required | No | Hostname or override from kubelet `--hostname-override`. kubelet registers the node with this name. |
| `metadata.labels` | Optional / Important | Yes (commonly edited) | Used for nodeSelector, affinity, and topology. Common labels: `node-role.kubernetes.io/worker`, `topology.kubernetes.io/zone`, `topology.kubernetes.io/region`. |
| `spec.taints` | Optional / Important | Yes (commonly edited) | Format: `key=value:effect`. Effects: `NoSchedule`, `PreferNoSchedule`, `NoExecute`. Repels pods without matching tolerations. |
| `status.capacity` | Important | No (read-only) | Total hardware resources (CPU, memory, pods). Set by kubelet at registration. |
| `status.allocatable` | Important | No (read-only) | Capacity minus system-reserved resources. The scheduler uses this to determine available resources for pods. |
| `status.conditions` | Important | No (read-only) | Reported by kubelet: `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`, `NetworkUnavailable`. CNI plugin sets `NetworkUnavailable`. |

> **Note:** The Node object is mostly read-only. Labels and taints are the fields most commonly edited with `kubectl edit`. The kubelet registers the node and reports capacity/conditions; the CNI plugin configures networking.
