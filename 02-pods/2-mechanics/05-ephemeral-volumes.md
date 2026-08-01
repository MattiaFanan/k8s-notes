# Ephemeral Volumes

Ephemeral volumes are temporary volumes that exist for the lifetime of a pod. Unlike persistent volumes, they are not backed by a separate storage system and are deleted when the pod is removed.

## Types of Ephemeral Volumes

### emptyDir

The simplest ephemeral volume. Created when the pod is assigned to a node and exists as long as the pod runs on that node. Data is lost when the pod is deleted.

```yaml
volumes:
- name: scratch
  emptyDir: {}
```

### CSI Ephemeral Volumes

CSI drivers can provide ephemeral volumes that are created on-demand and attached to the node. These are useful for injecting sidecar tools or configuration without a full PV/PVC setup.

```yaml
volumes:
- name: sidecar-tool
  csi:
    driver: sidecar.injector.example.com
    volumeAttributes:
      tool: "debug"
```

### configMap and secret (Ephemeral Usage)

ConfigMaps and Secrets mounted as volumes are ephemeral — they exist as long as the pod runs and are cleaned up when the pod is deleted.

```yaml
volumes:
- name: config
  configMap:
    name: app-config
- name: secret
  secret:
    secretName: db-creds
```

## Ephemeral Volumes in kubectl debug

`kubectl debug` creates an ephemeral container with an ephemeral volume for debugging purposes.

```bash
# Debug a running pod with an ephemeral container
kubectl debug mypod --image=busybox -it -- sh

# Debug a pod targeting a specific container
kubectl debug mypod --image=busybox --target=app -it -- sh
```

## Key Characteristics

| Property | emptyDir | CSI Ephemeral | configMap/secret |
|----------|----------|---------------|------------------|
| Persistence | Pod lifetime only | Pod lifetime only | Pod lifetime only |
| Backing store | Node disk | CSI driver | API server |
| Shared across containers | Yes | Yes | Yes |
| Survives pod restart | No | No | No |
| Requires PVC | No | No | No |

## Exam Relevance

- Ephemeral volumes are in CKAD scope under DB-04 (Utilize persistent and ephemeral volumes).
- `kubectl debug` with ephemeral containers is in CKAD scope under OM-05 (Debugging in Kubernetes).
- Understand the difference between ephemeral volumes and persistent volumes.
- Know when to use `emptyDir` vs `csi` ephemeral volumes vs `configMap`/`secret` volumes.

## Common Pitfalls

1. **Confusing ephemeral with persistent**: Ephemeral volumes are deleted when the pod is deleted. PVCs persist beyond pod lifetime.
2. **Forgetting emptyDir is node-local**: Data in `emptyDir` is lost if the pod is rescheduled to a different node.
3. **Not using ephemeral volumes for debug**: `kubectl debug` creates ephemeral containers with ephemeral volumes. Understand this workflow.

## Commands

```bash
# Create a pod with an emptyDir volume
kubectl run test-pod --image=busybox -it --restart=Never -- sh
# Inside the pod:
echo "hello" > /mnt/scratch/hello.txt
cat /mnt/scratch/hello.txt

# Debug a pod with an ephemeral container
kubectl debug mypod --image=busybox -it -- sh

# List ephemeral containers in a pod
kubectl get pod mypod -o jsonpath='{.spec.ephemeralContainers[*].name}'
```

## See also

- [Pods - YAML Structure](../../02-pods/1-yaml-structure.md)
- [Multi-Container Pods](../../02-pods/2-mechanics/00-multi-container-pods/2-mechanics/01-adapter-pattern.md)
- [Storage - YAML Structure](../../05-storage/1-yaml-structure.md)