# Multi-Container Pods - YAML Structure

A Pod can contain multiple containers that share the same network namespace, IPC, and volumes. This enables patterns like sidecars (auxiliary containers that augment the main container), init containers (setup tasks that must complete before app containers start), and adapters/proxies (containers that normalize or translate traffic). Multi-container pods allow co-located, tightly coupled workloads to share resources and lifecycles within a single scheduling unit.

## Sidecar Pattern

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: logging-app
spec:
  containers:
  - name: main-app
    image: main-app:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
  - name: sidecar-logger
    image: fluentbit:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
  volumes:
  - name: shared-logs
    emptyDir: {}
```

## Init Container Pattern

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting...; sleep 2; done;']
  - name: init-mydb
    image: busybox
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting...; sleep 2; done;']
  containers:
  - name: app
    image: nginx:1.25
```

## Adapter & Ambassador Pattern

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: adapter-demo
spec:
  containers:
  - name: main-app
    image: legacy-app:1.0
    env:
    - name: REST_PORT
      value: "8080"
  - name: adapter               # Normalizes metrics for Prometheus
    image: prometheus-adapter
    ports:
    - containerPort: 9100
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `apiVersion` | Required | No | Must be `v1` for Pods. Immutable after creation. |
| `kind` | Required | No | Must be `Pod` for this resource type. Immutable after creation. |
| `metadata.name` | Required | No | Unique name within the namespace. Immutable after creation. |
| `spec.containers` | Required | No | At least one container must be defined. Containers cannot be added or removed after creation. |
| `spec.containers[].name` | Required | No | Unique within the Pod. Immutable after creation. |
| `spec.containers[].image` | Required | **Yes** | Image reference (tag or digest). Can be updated in a running Pod. |
| `spec.containers[].volumeMounts` | Optional | No | Mount points into container filesystem. Must match a defined volume. Immutable after creation. |
| `spec.containers[].command` | Optional | No | Overrides the container's default entrypoint. Immutable after creation. |
| `spec.containers[].ports` | Optional | No | Declares the network port the container listens on. Immutable after creation. |
| `spec.containers[].env` | Optional | No | Environment variables passed to the container. Immutable after creation. |
| `spec.initContainers` | Optional | No | Init containers cannot be added or modified after Pod creation; delete and recreate the Pod. |
| `spec.volumes` | Optional | No | Defines shared storage. Immutable after creation. |
| `spec.volumes[].name` | Required | No | Must match the `name` in every container's `volumeMounts`. Immutable after creation. |
| `spec.volumes[].emptyDir` | Optional | No | Ephemeral storage shared across containers in the Pod. Immutable after creation. |

### Multi-Container Pattern Notes

- **Shared volumes**: Volume `name` values must match across `volumeMounts` entries in all containers that need to share data. A mismatch means the mount is silently ignored.
- **`initContainers`**: Non-editable after Pod creation. Use `kubectl edit` only for app containers; to modify init containers, delete and recreate the Pod.
- **Sidecars**: Added by editing the Pod spec directly (e.g., `kubectl edit pod`), not via imperative commands like `kubectl run` or `kubectl set`. Imperative commands do not support adding sidecar containers to an existing Pod.
