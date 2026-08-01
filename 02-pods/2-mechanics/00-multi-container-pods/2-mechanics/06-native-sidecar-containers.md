# Native Sidecar Containers (Kubernetes v1.28+)

Kubernetes v1.28 introduced native sidecar containers as a GA feature. Unlike traditional sidecars that run as regular containers alongside the main container, native sidecars use `restartPolicy: Always` on init containers, allowing them to run for the lifetime of the Pod alongside the main application container.

## Traditional Sidecar vs Native Sidecar

| Aspect | Traditional Sidecar | Native Sidecar (v1.28+) |
|--------|---------------------|--------------------------|
| Container type | Regular container in `spec.containers` | Init container with `restartPolicy: Always` |
| Lifecycle | Runs alongside main container for Pod lifetime | Runs alongside main container for Pod lifetime |
| Start order | Starts in parallel with main container | Starts after all regular init containers complete, then runs alongside main container |
| Use case | Service mesh proxies, log shippers | Same, but with guaranteed startup ordering |

## Why Native Sidecars Matter

Traditional sidecars (regular containers) start in parallel with the main application container. This means the sidecar and the main container race to start, which can cause issues if the sidecar needs to be ready before the application begins accepting traffic.

Native sidecars (init containers with `restartPolicy: Always`) start **after** all regular init containers complete but **before** the main application containers start. This guarantees the sidecar is ready before the application begins serving traffic.

## Native Sidecar YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-native-sidecar
spec:
  initContainers:
  - name: sidecar
    image: fluent/fluent-bit:latest
    command: ["fluent-bit", "-c", "/etc/fluent-bit/fluent-bit.conf"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
      readOnly: true
    restartPolicy: Always
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
  volumes:
  - name: logs
    emptyDir: {}
```

## Key Behavior

1. **Startup ordering**: Native sidecars start after all regular init containers complete, then run alongside the main container.
2. **Shared namespace**: Like all containers in a Pod, native sidecars share the Pod's network namespace, IPC namespace, and volumes.
3. **Restart behavior**: If a native sidecar crashes, it is restarted according to the Pod's `restartPolicy`.
4. **Resource sharing**: Native sidecars compete for the same node resources as the main container. Always set `resources.requests` and `resources.limits`.

## When to Use Native Sidecars

- **Service mesh proxies** (Envoy, Linkerd): The sidecar must be ready before the application starts accepting traffic.
- **Log shippers** (Fluent Bit, Filebeat): The sidecar should be running before the application starts writing logs.
- **Credential rotation** (Vault Agent): The sidecar needs to be running to refresh credentials before the application uses them.

## When NOT to Use Native Sidecars

- If the sidecar does not need to be ready before the main application starts, a traditional sidecar (regular container) is simpler.
- If the sidecar logic can be implemented as an init container that runs once and exits, use a regular init container instead.
- If the sidecar needs to run on every node (not per-Pod), use a DaemonSet instead.

## Exam Relevance

- Native sidecar containers are in CKAD scope under DB-03 (Understand multi-container Pod design patterns).
- Know the difference between traditional sidecars (regular containers) and native sidecars (init containers with `restartPolicy: Always`).
- Understand the startup ordering: init containers → native sidecars → main containers.

## Common Pitfalls

1. **Forgetting `restartPolicy: Always`**: Without this field, the init container runs once and exits, behaving like a traditional init container rather than a sidecar.
2. **Confusing native sidecars with regular init containers**: Regular init containers run sequentially and exit; native sidecars run alongside the main container for the Pod's lifetime.
3. **Not setting resource limits**: Native sidecars share the same node resources as the main container. Without limits, a sidecar can starve the main container.
4. **Assuming native sidecars start before regular init containers**: Native sidecars start after all regular init containers complete, not before them.