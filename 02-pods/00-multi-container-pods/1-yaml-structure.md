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
| `apiVersion` | Required | Yes | Must be `v1` for Pods. |
| `kind` | Required | Yes | Must be `Pod` for this resource type. |
| `metadata.name` | Required | Yes | Unique name within the namespace. |
| `spec.containers` | Required | Yes | Each container must have a unique `name` within the Pod. |
| `spec.containers[].name` | Required | Yes | Used to reference the container in `volumeMounts` and `dependsOn`. |
| `spec.containers[].image` | Required | Yes | Image reference (tag or digest). |
| `spec.containers[].volumeMounts` | Optional | Yes | `name` must match a volume in `spec.volumes`. Shared volumes allow sidecars to read/write the same data. |
| `spec.containers[].command` | Optional | Yes | Overrides the container's default entrypoint. |
| `spec.containers[].ports` | Optional | Yes | Declares the network port the container listens on. |
| `spec.containers[].env` | Optional | Yes | Environment variables passed to the container. |
| `spec.initContainers` | Optional | **No** (non-editable after creation) | Run to completion before app containers start. Cannot be modified after Pod creation; delete and recreate the Pod to change them. |
| `spec.volumes` | Optional | Yes | Defines shared storage. Volume `name` must match `volumeMounts.name` across all containers that share it. |
| `spec.volumes[].name` | Required | Yes | Must match the `name` in every container's `volumeMounts` that needs access to that volume. |
| `spec.volumes[].emptyDir` | Optional | Yes | Ephemeral storage shared across containers in the Pod. |

### Multi-Container Pattern Notes

- **Shared volumes**: Volume `name` values must match across `volumeMounts` entries in all containers that need to share data. A mismatch means the mount is silently ignored.
- **`initContainers`**: Non-editable after Pod creation. Use `kubectl edit` only for app containers; to modify init containers, delete and recreate the Pod.
- **Sidecars**: Added by editing the Pod spec directly (e.g., `kubectl edit pod`), not via imperative commands like `kubectl run` or `kubectl set`. Imperative commands do not support adding sidecar containers to an existing Pod.
