# Storage - YAML Structure

Kubernetes provides persistent storage through PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs). A PV is a cluster-administered volume, while a PVC is a user's request for that storage. StorageClasses define the type and provisioning behavior of storage. The examples below show how to define PVs, PVCs, StorageClasses, and how to mount a PVC into a Pod.

%comment make sure somewhere in this argoment folder, the fact that pv and pvc exist is to decouple pod volume usage and physical volume properties
a pod says i want 10Gi and uses a pvc, but the admin can later change the type to cloud or local or a different cloud without the pod having to modify its yaml

## PersistentVolume (PV) Manifest

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local
  hostPath:
    path: /mnt/data
```
%comment hostpath pv without nodeaffinity is not really usefull, add somewhere this class 
 local workflow
 Corrected & Unified Workflow: Local hostpath & Node Affinity (With Pending States)
A hostPath PV without a nodeAffinity is practically useless in a multi-node cluster because Kubernetes has no way of knowing which physical machine's hard drive holds the data.
To make local storage work seamlessly, Kubernetes relies on one of two workflows:
Workflow 1: Static Local PVs (Manual)
 * The Setup: You manually create a PV with a strict nodeAffinity pointing to a specific node (e.g., Worker-Node-A).
 * The Pod & Scheduler: When a pod requests a PVC bound to that static PV, the scheduler reads the PV's nodeAffinity.
 * The Enforcement & The Pending State: The scheduler functionally forces the Pod to inherit that constraint.
   * If Worker-Node-A is healthy: The pod lands on it.
   * If Worker-Node-A is down, full, or doesn't exist: The scheduler refuses to place the pod anywhere else. The pod gets stuck in a Pending state indefinitely, throwing an event warning about a node affinity mismatch.
Workflow 2: Dynamic Local Storage Class (Automated / CSI)
Using tools like the Local Path Provisioner with WaitForFirstConsumer binding mode.
 * The Request: A developer creates a PVC (no PV exists yet). Because of WaitForFirstConsumer, nothing happens immediately, and the pod sits Pending until scheduled.
 * The Scheduler Steps In: A Pod requests that PVC. The scheduler looks at the cluster, picks an optimal node (e.g., Worker-Node-B), and locks it in.
 * The CSI Trigger: Once the node is chosen, the CSI storage controller wakes up, reads the target node, and executes the physical actions:
   * It creates the local folder on Worker-Node-B.
   * It dynamically generates the PV object on the fly.
   * It automatically stamps that new PV with a nodeAffinity pointing directly to Worker-Node-B.
 * The Failure / Pending State: If the CSI driver encounters an error (e.g., it fails to create the folder on Worker-Node-B due to permissions or disk space), the provisioning fails, and the pod remains stuck in a Pending state while reporting the storage error in its events.

## PersistentVolumeClaim (PVC) Manifest

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local
```

## StorageClass Manifest

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

## Pod Using PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: data
    persistentVolumeClaim:
       claimName: my-pvc
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `spec.capacity.storage` (PV) | Required | No | Defines the PV size; must be set at creation time |
| `spec.accessModes` (PV, PVC) | Required | No (after binding) | Must match between PV and PVC; common values: `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany` |
| `spec.persistentVolumeReclaimPolicy` (PV) | Important | Yes | `Retain` keeps data after PVC deletion, `Delete` removes the backing storage, `Recycle` scrubs data (deprecated in newer K8s) |
| `spec.storageClassName` (PV, PVC, StorageClass) | Important | Yes | PV and PVC must share the same `storageClassName` for dynamic binding; omitting it uses the default StorageClass |
| `spec.hostPath.path` (PV) | Required (for local PV) | No | Required when PV type is `hostPath`; path must exist on the node |
| `spec.local.path` (PV) | Required (for local PV) | No | Required for `local` PV type; volume must be pre-provisioned on the node |
| `spec.resources.requests.storage` (PVC) | Required | No (after binding) | Size of storage requested; must be ≤ PV capacity |
| `spec.provisioner` (StorageClass) | Required | Yes | Identifier of the volume provisioner plugin (e.g., `ebs.csi.aws.com`) |
| `spec.reclaimPolicy` (StorageClass) | Important (default: Delete) | Yes | `Delete` removes backing storage when PVC is deleted; `Retain` preserves it |
| `spec.allowVolumeExpansion` (StorageClass) | Important | Yes | Set to `true` to allow PVCs to be resized without recreating the PVC |
| `spec.volumeBindingMode` (StorageClass) | Optional | Yes | `WaitForFirstConsumer` delays binding until a pod uses the PVC; useful for topology-aware provisioning |
| `volumeMounts[].mountPath` (Pod) | Required | Yes | Container path where the volume is mounted; must be an absolute path |
| `volumeMounts[].name` (Pod) | Required | Yes | Must match `volumes[].name` in the same pod spec |
| `volumes[].persistentVolumeClaim.claimName` (Pod) | Required | Yes | Name of the PVC to mount; PVC must exist in the same namespace |
| `volumes[].emptyDir` (Pod) | Optional | Yes | Creates a temporary directory; does not require a PVC; data is lost on pod restart |
| `volumes[].hostPath` (Pod) | Optional | Yes | Mounts a node directory into the pod; does not require a PVC; use for node-level access |
| **Scope: PV** | Cluster-scoped | — | PVs are not namespaced; they are available cluster-wide |
| **Scope: PVC, Pod** | Namespace-scoped | — | PVCs and Pods are namespaced; a PVC can only bind to a PV in the same namespace context |
