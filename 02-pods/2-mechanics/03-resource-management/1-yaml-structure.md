# Resource Management - YAML Structure

Resource management in Kubernetes ensures that pods consume fair and bounded amounts of CPU and memory. Requests define the minimum guaranteed resources, while limits set the maximum a container can use. LimitRanges apply default requests and limits to containers in a namespace, and ResourceQuotas enforce hard limits across all pods in a namespace. The examples below show how to configure per-pod resources, namespace-level limit ranges, and namespace-level resource quotas.

## Pod with CPU/Memory Resources

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: nginx:1.25
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "250m"
        memory: "256Mi"
```

## LimitRange (Namespace Defaults)

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: default
spec:
  limits:
  - default:
      cpu: "250m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

## ResourceQuota (Namespace Hard Limits)

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-quota
  namespace: default
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20"
    configmaps: "20"
    secrets: "20"
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `resources.requests.cpu` | Important | Yes | Used by the scheduler for node placement. Expressed in millicores (e.g. `100m`) or decimal (e.g. `0.1`). Both are valid. |
| `resources.requests.memory` | Important | Yes | Minimum guaranteed memory for the container. Use binary units (`Mi`, `Gi`). |
| `resources.limits.cpu` | Optional | Yes | Maximum CPU enforced by cgroups. Throttling occurs when this limit is exceeded. Decimal values like `0.1` are valid, though `m` suffix is preferred for sub-core values. |
| `resources.limits.memory` | Optional | Yes | Maximum memory enforced by cgroups. Exceeding this triggers OOMKill (Exit Code 137). Use binary units (`Mi`, `Gi`). |
| `spec.limits[].type` (LimitRange) | Important | Yes | Scope of the limit: `Container`, `Pod`, or `PVC`. |
| `spec.limits[].default` (LimitRange) | Important | Yes | Default limit applied to containers that omit `resources.limits`. |
| `spec.limits[].defaultRequest` (LimitRange) | Important | Yes | Default request applied to containers that omit `resources.requests`. |
| `spec.hard` (ResourceQuota) | Required | Yes | Hard limits for the namespace. Must specify at least one scope. Can restrict `pods`, `cpu`, `memory`, `secrets`, `configmaps`, and more. |
| QoS class | — | No | `Guaranteed` when requests == limits; `Burstable` when requests < limits; `BestEffort` when no requests/limits set. |
| OOMKill exit code | — | No | Exit Code 137 occurs when a container exceeds its memory limit and is killed by the OOM killer. |
| CPU throttling | — | No | Occurs when a container's CPU usage exceeds its `resources.limits.cpu` value. |

### Key Concepts

- **requests vs limits**: `requests` are used by the scheduler for placement decisions; `limits` are enforced by cgroups at runtime.
- **CPU units**: Use millicores (e.g. `100m`) or decimal notation (e.g. `0.1`). Both are valid; `m` suffix is preferred for sub-core values.
- **Memory units**: Use binary units such as `128Mi` or `1Gi`. Binary units are preferred over decimal (e.g. `MB`).
- **LimitRange**: Sets default requests and limits per `Container`, `Pod`, or `PVC` type in a namespace.
- **ResourceQuota**: Enforces hard limits across all pods in a namespace. The `hard` field is required.
- **QoS classes**: `Guaranteed` (requests == limits), `Burstable` (requests < limits), `BestEffort` (no requests or limits).
- **OOMKill**: Results in Exit Code 137 when a container exceeds its memory limit.
- **Throttling**: Occurs when CPU usage exceeds the configured CPU limit.
