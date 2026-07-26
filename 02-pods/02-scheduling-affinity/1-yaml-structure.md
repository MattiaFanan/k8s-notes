# Pods - Scheduling Affinity - YAML Structure

Scheduling affinity lets you influence which nodes a pod is placed on based on labels on the nodes or on other pods already running. **Node affinity** rules constrain scheduling to nodes that match certain label criteria, while **pod affinity** and **pod anti-affinity** rules constrain scheduling based on labels of pods already running on the same node. Affinity can be set as `requiredDuringSchedulingIgnoredDuringExecution` (hard rule) or `preferredDuringSchedulingIgnoredDuringExecution` (soft rule with a weight). This is commonly used to co-locate related services or to spread replicas across failure domains like zones or hosts.

## Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
            - linux
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: node-role.kubernetes.io/worker
            operator: Exists
```

## Pod Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-affinity-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: web
        topologyKey: topology.kubernetes.io/zone
```

## Pod Anti-Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-antiaffinity-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: web
        topologyKey: kubernetes.io/hostname
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: web
          topologyKey: topology.kubernetes.io/zone
```

## Key Operators

- `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `affinity.nodeAffinity` | Optional | Yes (`kubectl edit pod`) | Use `requiredDuringSchedulingIgnoredDuringExecution` for hard constraints and `preferredDuringSchedulingIgnoredDuringExecution` for soft (weighted) preferences. |
| `nodeSelector` | Optional | Yes (`kubectl edit pod`) | Simpler alternative to `nodeAffinity` for single-label equality checks only. |
| `affinity.podAffinity` / `affinity.podAntiAffinity` | Optional | Yes (`kubectl edit pod`) | Same required vs preferred structure as node affinity. `topologyKey` is required in every term. |
| `requiredDuringSchedulingIgnoredDuringExecution` | Optional (within affinity) | Yes (`kubectl edit pod`) | Hard rule — pod is scheduled only if the rule is satisfied. The rule is ignored if the node later no longer matches (e.g., label change). |
| `preferredDuringSchedulingIgnoredDuringExecution` | Optional (within affinity) | Yes (`kubectl edit pod`) | Soft rule — scheduler prefers nodes matching the rule but will still schedule elsewhere. Uses `weight` (1–100) to rank preferences. |
| `operator` (In, NotIn, Exists, DoesNotExist, Gt, Lt) | Optional (defaults to `In` for matchExpressions) | N/A (set in YAML) | `In`/`NotIn` require `values`; `Exists`/`DoesNotExist` do not; `Gt`/`Lt` compare numeric values. |
| `topologyKey` | Required (for podAffinity/podAntiAffinity) | N/A (set in YAML) | Defines the domain for co-location or spreading (e.g., `kubernetes.io/hostname`, `topology.kubernetes.io/zone`). |
| `weight` | Required (for preferred rules) | N/A (set in YAML) | Integer from 1 to 100; higher weight = stronger preference. Only used in `preferredDuringSchedulingIgnoredDuringExecution`. |
| Node labels | N/A | Yes (`kubectl label nodes`) | Labels on nodes are edited with `kubectl label`, not `kubectl edit` on pods. Affinity rules reference these labels. |
| IgnoredDuringExecution semantics | N/A | N/A | Rules apply only at scheduling time. A node that loses a required label after scheduling will not cause pod eviction. |
