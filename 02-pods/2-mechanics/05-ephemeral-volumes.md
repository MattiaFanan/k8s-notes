# Ephemeral Volumes

Ephemeral volumes are temporary volumes that exist for the lifetime of a pod. Unlike persistent volumes, they are not backed by a separate storage system and are deleted when the pod is removed. Understanding the differences between ephemeral and persistent storage, and when to use each type, is critical for the CKAD exam.

## emptyDir

`emptyDir` is the most common ephemeral volume. It is created when a pod is assigned to a node and exists as long as the pod runs on that node. When the pod is removed, `emptyDir` is deleted permanently.

### Key characteristics:
- Ephemeral — tied to pod lifecycle
- Backed by the node's disk (default) or `tmpfs` (RAM-backed)
- Shared between all containers in the same pod via the volume mount
- Not accessible across pods
- Survives container restarts within the same pod

```yaml
volumes:
- name: scratch
  emptyDir: {}
```

### RAM-backed emptyDir (tmpfs)

```yaml
volumes:
- name: ram-cache
  emptyDir:
    medium: Memory
    sizeLimit: 100Mi
```

### When to use emptyDir:
- Temporary scratch space for intermediate processing
- Shared data between init containers and app containers
- Caching frequently-recomputed data that does not need to survive pod restarts
- Multi-container pods where one container generates data and another consumes it

### Common Pitfall: emptyDir is node-local

Data in `emptyDir` is lost if the pod is rescheduled to a different node. For data that must survive pod restarts or node changes, use a PVC instead.

## CSI Ephemeral Volumes

CSI drivers can provide ephemeral volumes that are created on-demand and attached to the node. These are useful for injecting sidecar tools or configuration without a full PV/PVC setup.

```yaml
volumes:
- name: sidecar-tool
  csi:
    driver: ebs.csi.aws.com
    volumeAttributes:
      tool: "debug"
```

### When to use CSI ephemeral volumes:
- When you need a volume that is managed by a CSI driver but does not need to persist beyond the pod lifetime
- Some CSI drivers (e.g., secrets store CSI driver) use ephemeral volumes to inject secrets directly into pods without creating Kubernetes Secret objects

### Common Pitfall: CSI ephemeral volumes require CSI driver support

Not all CSI drivers support ephemeral volumes. Check the driver documentation for support.

## configMap and secret (Ephemeral Usage)

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

### Important: ConfigMap/Secret updates do not propagate to subPath mounts

If you mount a ConfigMap or Secret key using `subPath`, the mounted file is NOT updated when the ConfigMap or Secret changes. Use full volume mounts (without `subPath`) for auto-updates.

## Ephemeral Volumes in kubectl debug

`kubectl debug` creates an ephemeral container with an ephemeral volume for debugging purposes.

```bash
# Debug a running pod with an ephemeral container
kubectl debug mypod --image=busybox -it -- sh

# Debug a pod targeting a specific container
kubectl debug mypod --image=busybox --target=app -it -- sh
```

### Key characteristics of ephemeral containers:
- They are temporary and cannot be restarted
- They share the network and process namespace of the target container
- They can access the same volumes as the target container
- They are not added to the pod's `containers` list; they appear under `ephemeralContainers`

## Key Characteristics Comparison

| Property | emptyDir | CSI Ephemeral | configMap/secret |
|----------|----------|---------------|------------------|
| Persistence | Pod lifetime only | Pod lifetime only | Pod lifetime only |
| Backing store | Node disk or RAM | CSI driver | API server |
| Shared across containers | Yes | Yes | Yes |
| Survives pod restart | Yes (within same pod) | No | Yes (within same pod, if not using subPath) |
| Requires PVC | No | No | No |
| Auto-updates on change | N/A | N/A | Yes (if not using subPath) |

## Exam Relevance

- Ephemeral volumes are in CKAD scope under DB-04 (Utilize persistent and ephemeral volumes).
- `kubectl debug` with ephemeral containers is in CKAD scope under OM-05 (Debugging in Kubernetes).
- Understand the difference between ephemeral volumes and persistent volumes.
- Know when to use `emptyDir` vs `csi` ephemeral volumes vs `configMap`/`secret` volumes.

## Common Pitfalls

1. **Confusing ephemeral with persistent**: Ephemeral volumes are deleted when the pod is deleted. PVCs persist beyond pod lifetime.
2. **Forgetting emptyDir is node-local**: Data in `emptyDir` is lost if the pod is rescheduled to a different node.
3. **Using subPath with ConfigMap/Secret volumes**: subPath mounts do NOT auto-update when the ConfigMap or Secret changes.
4. **Not using ephemeral volumes for debug**: `kubectl debug` creates ephemeral containers with ephemeral volumes. Understand this workflow.
5. **Using emptyDir for data that must survive pod deletion**: Use PVCs for persistent data.

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
- [Storage - Common CKAD Storage Types](../../05-storage/2-mechanics/02-common-ckad-storage-types.md)
