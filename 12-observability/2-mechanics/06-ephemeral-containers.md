# Ephemeral Containers and kubectl debug

Ephemeral containers are special containers that can be injected into a running pod for debugging purposes. They are not part of the pod's regular container set and are automatically removed when the pod is deleted.

## What Are Ephemeral Containers?

Ephemeral containers are temporary containers that share the same namespace and IPC namespace as the target container. They are used for debugging without modifying the pod's original configuration.

### Key Characteristics

- Share the same network namespace, PID namespace, and IPC namespace as the target container.
- Do not restart on failure (unlike regular containers).
- Are not managed by the pod's restart policy.
- Are automatically removed when the pod is deleted.
- Cannot be added to a pod spec permanently — they are injected at runtime.

## kubectl debug

The `kubectl debug` command creates an ephemeral container in a running pod for debugging.

### Basic Debug Session

```bash
# Debug a pod with a busybox ephemeral container
kubectl debug mypod -n myns --image=busybox -it -- sh

# Debug a specific container in a multi-container pod
kubectl debug mypod -n myns --image=busybox --target=app -it -- sh
```

### Flags

| Flag | Description |
|------|-------------|
| `--image` | Image to use for the ephemeral container |
| `--target` | Name of the container to share namespace with |
| `-it` | Interactive terminal |
| `--copy-to` | Copy the pod spec to a new pod for debugging |
| `--replace` | Replace the original pod with a debug copy |

### Copy-to Mode

Create a copy of the pod with an ephemeral container for non-disruptive debugging:

```bash
kubectl debug mypod -n myns --image=busybox --copy-to=debug-mypod -- sh
```

This creates a new pod `debug-mypod` with the same spec as `mypod` plus an ephemeral container.

### Replace Mode

`--replace` must be used together with `--copy-to`. It deletes the original pod and creates a new one with an ephemeral container.

```bash
kubectl debug mypod -n myns --image=busybox --copy-to=debug-mypod --replace -- sh
```

This creates a new pod `debug-mypod`, deletes the original pod `mypod`, and starts the debug pod with an ephemeral container.

## Ephemeral Container YAML

Ephemeral containers are defined in `spec.ephemeralContainers`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  ephemeralContainers:
  - name: debug
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    stdin: true
    tty: true
    targetContainerName: app
```

### Ephemeral Container Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Name of the ephemeral container |
| `image` | Yes | Container image |
| `command` | No | Override the image entrypoint |
| `args` | No | Override the image CMD |
| `stdin` | No | Keep stdin open |
| `tty` | No | Allocate a TTY |
| `targetContainerName` | No | Share namespace with this container |
| `env` | No | Environment variables |
| `volumeMounts` | No | Mount volumes |
| `resources` | No | Resource requests/limits |
| `securityContext` | No | Security context |

## Use Cases

### Debugging Network Issues

```bash
kubectl debug mypod -n myns --image=nicolaka/netshoot -it -- sh
# Inside the container:
curl http://my-svc.my-namespace.svc.cluster.local
nslookup my-svc.my-namespace.svc.cluster.local
ping my-svc.my-namespace.svc.cluster.local
```

### Debugging File System Issues

```bash
kubectl debug mypod -n myns --image=busybox -it -- sh
# Inside the container:
ls /mnt/data
cat /etc/config/app.properties
```

### Debugging Permission Issues

```bash
kubectl debug mypod -n myns --image=busybox -it -- sh
# Inside the container:
id
ls -la /var/log/app
cat /proc/1/status
```

### Debugging a Specific Container in a Multi-Container Pod

```bash
kubectl debug mypod -n myns --image=busybox --target=sidecar -it -- sh
# This shares the sidecar container's namespace
```

## Exam Relevance

- `kubectl debug` is in CKAD scope under OM-05 (Debugging in Kubernetes).
- Ephemeral containers are a key debugging tool for troubleshooting running pods.
- Know the difference between `kubectl debug` (ephemeral container) and `kubectl exec` (exec into existing container).
- Understand `--target` flag for sharing namespace with a specific container.
- Understand `--copy-to` and `--replace` modes.

## Common Pitfalls

1. **Using `kubectl debug` on a pod that is not running**: Ephemeral containers can only be added to running pods.
2. **Forgetting `--target`**: Without `--target`, the ephemeral container shares the pod's default namespace, not the target container's namespace.
3. **Confusing ephemeral containers with init containers**: Ephemeral containers run after all init containers have completed and alongside regular containers. Init containers run before any regular container starts.
4. **Not cleaning up ephemeral containers**: They persist until the pod is deleted.

## Commands

```bash
# Debug a pod
kubectl debug mypod -n myns --image=busybox -it -- sh

# Debug a specific container
kubectl debug mypod -n myns --image=busybox --target=app -it -- sh

# Debug with copy-to mode
kubectl debug mypod -n myns --image=busybox --copy-to=debug-pod -- sh

# Debug with replace mode
kubectl debug mypod -n myns --image=busybox --replace -- sh

# List ephemeral containers in a pod
kubectl get pod mypod -n myns -o jsonpath='{.spec.ephemeralContainers[*].name}'

# Check ephemeral container logs
kubectl logs mypod -n myns -c debug
```

## See also

- [Pods - CKAD Tips](../../02-pods/5-ckad-tips.md)
- [Observability Tools](04-observability-tools.md)
- [Debugging Workflow](05-debugging-workflow.md)