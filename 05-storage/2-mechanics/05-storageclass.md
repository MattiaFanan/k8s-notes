# Storage - StorageClass Deep Dive

## Overview

A `StorageClass` provides a way for administrators to describe "classes" of storage they offer. Each StorageClass defines a provisioner (the CSI driver or external plugin that creates the storage) and parameters that control how the storage is provisioned. When a PersistentVolumeClaim (PVC) references a StorageClass, the provisioner automatically creates a matching PersistentVolume (PV).

## StorageClass Structure

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

### Core Fields

| Field | Required | Description |
|-------|----------|-------------|
| `metadata.name` | Yes | Name of the StorageClass (used in PVC `storageClassName`) |
| `provisioner` | Yes | The CSI driver or external provisioner that creates PVs |
| `parameters` | No | Provisioner-specific parameters (varies by driver) |
| `reclaimPolicy` | No | Default reclaim policy for dynamically provisioned PVs (`Delete` or `Retain`) |
| `allowVolumeExpansion` | No | Whether PVCs using this class can be expanded after creation |
| `volumeBindingMode` | No | `Immediate` (default) or `WaitForFirstConsumer` |
| `mountOptions` | No | Default mount options for the PV (driver-dependent) |

## Provisioners

The `provisioner` field determines which CSI driver handles volume creation. Common provisioners:

| Provisioner | Cloud Provider | Typical Use |
|-------------|---------------|-------------|
| `ebs.csi.aws.com` | AWS | EBS volumes |
| `pd.csi.storage.gke.io` | GCP | GCE Persistent Disks |
| `disk.csi.azure.com` | Azure | Azure Managed Disks |
| `file.csi.azure.com` | Azure | Azure Files |
| `nfs.csi.k8s.io` | Any | NFS shares |
| `csi.vsphere.vmware.com` | vSphere | vSphere volumes |
| `rancher.io/local-path` | Any | Local storage on node |

## Parameters

Parameters are provisioner-specific. Common parameters for popular provisioners:

### AWS EBS (`ebs.csi.aws.com`)

| Parameter | Values | Description |
|-----------|--------|-------------|
| `type` | `gp2`, `gp3`, `io1`, `io2`, `st1`, `sc1` | EBS volume type |
| `iops` | Integer | IOPS for `io1`/`io2` volumes |
| `throughput` | Integer | Throughput in MB/s (for `gp3`) |
| `encrypted` | `"true"`, `"false"` | Whether to encrypt the volume |
| `kmsKeyId` | ARN | KMS key for encryption |

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
  throughput: "125"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### GCE PD (`pd.csi.storage.gke.io`)

| Parameter | Values | Description |
|-----------|--------|-------------|
| `type` | `pd-standard`, `pd-balanced`, `pd-ssd` | PD volume type |
| `replication-type` | `none`, `regional-pd` | Replication strategy |
| `disk-encryption-kms-key` | Key resource name | KMS key for encryption |

### Azure Disk (`disk.csi.azure.com`)

| Parameter | Values | Description |
|-----------|--------|-------------|
| `storageaccounttype` | `Standard_LRS`, `Premium_LRS`, `StandardSSD_LRS` | Storage account type |
| `kind` | `Shared`, `Dedicated`, `Managed` | Disk kind |

## Reclaim Policy

The `reclaimPolicy` determines what happens to the PV when its bound PVC is deleted.

| Policy | Behavior | Use Case |
|--------|----------|----------|
| `Delete` | PV and underlying storage are deleted when PVC is deleted | Dev/test, ephemeral data |
| `Retain` | PV is kept but marked as `Released`; data persists | Production, critical data |

**Default**: Most CSI drivers default to `Delete`. Static PVs can have either policy set explicitly.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: persistent-storage
provisioner: ebs.csi.aws.com
reclaimPolicy: Retain
```

## Volume Binding Modes

### Immediate (Default)

PV is provisioned and bound as soon as the PVC is created, regardless of whether a Pod is actually using it yet.

**Implications:**
- PV is created immediately — storage capacity is consumed right away
- Binding happens at PVC creation time
- Pod may be scheduled on any node — the PV might be in a different availability zone
- Works well for storage backends that do not care about topology (e.g., NFS)

### WaitForFirstConsumer

PV is not provisioned until a Pod that uses the PVC is scheduled. This allows the scheduler to choose a node (and thus an availability zone) first, ensuring the PV is provisioned in the same zone.

**Why WaitForFirstConsumer is recommended for zonal storage:**
- AWS EBS volumes are **zone-locked**. If you use `Immediate` binding, the PV might be created in `us-east-1a` but the Pod could be scheduled on a node in `us-east-1b`, causing the Pod to be stuck in `Pending`.
- `WaitForFirstConsumer` defers provisioning until scheduling, ensuring the zone matches.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: zonal-ssd
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
  encrypted: "true"
```

## Volume Expansion

When `allowVolumeExpansion: true` is set on a StorageClass, PVCs using that class can be expanded after creation:

```bash
# Expand a PVC from 20Gi to 30Gi
kubectl patch pvc my-pvc -p '{"spec": {"resources": {"requests": {"storage": "30Gi"}}}}'
```

**Important notes:**
- Expansion is supported for some filesystems (e.g., ext4, xfs) but not all.
- The Pod using the PVC may need to be restarted for the filesystem to recognize the new size.
- Not all CSI drivers support expansion.

## Default StorageClass

One StorageClass can be marked as the default so that PVCs without an explicit `storageClassName` still trigger dynamic provisioning:

```bash
# Mark a StorageClass as default
kubectl patch storageclass fast-ssd -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
```

**Note:** Multiple default StorageClasses can coexist in a cluster. When more than one is marked as default, Kubernetes uses the most recently created default StorageClass for PVCs that do not specify a `storageClassName`.

## StorageClass YAML Structure Reference

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-storage-class
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  encrypted: "true"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
mountOptions:
  - debug
```

## StorageClass Commands

```bash
# List all StorageClasses
kubectl get storageclass

# Describe a StorageClass
kubectl describe storageclass fast-ssd

# Check which StorageClass is the default
kubectl get storageclass -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}{"\n"}{end}'

# Create a StorageClass
kubectl apply -f storageclass.yaml

# Delete a StorageClass
kubectl delete storageclass fast-ssd
```

## Best Practices

1. **Always use `volumeBindingMode: WaitForFirstConsumer`** for zonal storage backends (AWS EBS, GCE PD, Azure Disk) to avoid zone mismatch issues.
2. **Use `allowVolumeExpansion: true`** for workloads that may grow.
3. **Set `reclaimPolicy: Retain`** for production data to prevent accidental data loss.
4. **Create a default StorageClass** for convenience, but ensure it matches your most common use case.
5. **Use distinct StorageClasses** for different workload tiers (production vs. dev, SSD vs. HDD).
6. **Enable encryption** for sensitive data (most cloud providers support it).

## Common Pitfalls

1. **PVC stuck in `Pending` with zone mismatch**: The StorageClass uses `Immediate` binding with a zonal provisioner. Switch to `WaitForFirstConsumer`.
2. **Data lost after PVC deletion**: The reclaim policy is `Delete`. Switch to `Retain` for critical data.
3. **Expansion fails**: The StorageClass does not have `allowVolumeExpansion: true`, or the CSI driver does not support expansion.
4. **Multiple default StorageClasses**: Only one default StorageClass is allowed. Delete or unset the default annotation on extra classes.
5. **Wrong provisioner**: The provisioner name must match an installed CSI driver. Check with `kubectl get csidrivers`.

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| PVC stuck in `Pending` | No matching StorageClass or provisioner not installed | `kubectl get storageclass`; check CSI driver pods |
| PVC stuck in `Pending` with ZoneMismatch | PV in different AZ than scheduled node | Use `WaitForFirstConsumer` binding mode |
| Pod stuck in `ContainerCreating` | PV not yet provisioned (dynamic) | Check provisioner logs; verify StorageClass provisioner |
| Data lost after PVC deletion | Reclaim policy was `Delete` | Switch to `Retain` and back up data proactively |
| Expansion fails | StorageClass does not allow `allowVolumeExpansion` | Check StorageClass config |

## CKAD Exam Tips

- If a PVC is stuck in `Pending`, check `kubectl describe pvc` for the StorageClass name and events.
- If the question asks you to "ensure data is preserved after PVC deletion", set the reclaim policy to `Retain`.
- If the question involves creating a PVC with dynamic provisioning, always reference a StorageClass.
- Use `WaitForFirstConsumer` for zonal storage to avoid scheduling issues.

## See also

- [Storage - YAML Structure](../../05-storage/1-yaml-structure.md)
- [Storage - Access Modes](../../05-storage/2-mechanics/01-access-modes.md)
- [Storage - Volume Lifecycle & Binding](../../05-storage/2-mechanics/04-volume-lifecycle-binding.md)
- [Storage - Reclaim Policies](../../05-storage/2-mechanics/03-reclaim-policies.md)
