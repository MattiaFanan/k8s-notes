# Pod Security Standards — Core Concepts

Pod Security Standards (PSS) define three baseline policies that constrain security contexts on pods. They replaced the deprecated PodSecurityPolicy (PSP) which was removed in Kubernetes 1.25.

## The Three PSS Policies

### Privileged

No restrictions. Equivalent to running without any security policies. Allows privileged containers, host namespaces, host paths, and all capabilities.

- Use case: System-level components that need full host access (e.g., CNI plugins, kube-proxy).
- **Never use for application workloads.**

### Baseline

Minimal restrictions that prevent known privilege escalations. Does not restrict access to host namespaces, capabilities, or SELinux, but prevents running as root and privilege escalation.

- `runAsNonRoot: true` (or `runAsUser` != 0)
- `allowPrivilegeEscalation: false`
- No privileged containers

### Restricted

Strongest restrictions. Enforces the most secure defaults based on current best practices.

- `runAsNonRoot: true`
- `runAsUser` must be non-zero
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true`
- `capabilities: { drop: ["ALL"] }`
- No privileged containers
- No `SYS_ADMIN`, `NET_ADMIN`, or other dangerous capabilities
- `seccompProfile: RuntimeDefault` recommended

## PSS vs PodSecurityPolicy

| Aspect | PodSecurityPolicy (PSP) | Pod Security Standards (PSS) |
|--------|------------------------|------------------------------|
| Status | Removed in K8s 1.25 | Current standard |
| Enforcement | Admission controller | Pod Security Admission (PSA) |
| Configuration | Custom resource | Namespace labels |
| Complexity | Complex, many fields | Simple, three policies |
| Migration | N/A | Use PSA to enforce PSS |

## Pod Security Admission (PSA)

PSA is the admission controller that enforces PSS at the namespace or cluster level. It evaluates pods against the PSS labels on their namespace.

### PSA Enforcement Modes

| Mode | Label | Behavior |
|------|-------|----------|
| Enforce | `pod-security.kubernetes.io/enforce` | Rejects pods that violate the policy |
| Warn | `pod-security.kubernetes.io/warn` | Adds warning annotations to violating pods |
| Audit | `pod-security.kubernetes.io/audit` | Logs violations to the audit log |

### Checking PSA Status

```bash
# Check namespace PSS labels
kubectl get namespace myns --show-labels

# Check if PSA is enabled on the API server
ps aux | grep kube-apiserver | grep -i pod-security

# Test PSA enforcement
kubectl apply -f privileged-pod.yaml -n myns
# Expected: rejection if enforce=restricted or enforce=baseline
```

## Common Exam Scenarios

### Scenario 1: Pod Rejected by PSA

**Symptom**: Pod creation fails with a message about Pod Security Standards.

**Diagnosis**: The namespace has a PSS label that the pod violates.

**Fix**: Add the required security context fields to the pod spec, or change the namespace's PSS label.

### Scenario 2: Pod Runs as Root Despite runAsNonRoot

**Symptom**: Pod is running as UID 0 even though `runAsNonRoot: true` is set.

**Diagnosis**: The container image's `USER` directive sets UID 0. `runAsNonRoot` only prevents UID 0 if the image does not explicitly set a user.

**Fix**: Override with `runAsUser` in the pod spec, or rebuild the image with a non-root user.

### Scenario 3: Privileged Pod Needed for System Component

**Symptom**: A system component (e.g., CNI plugin, node agent) needs privileged access.

**Diagnosis**: The namespace has a PSS label that forbids privileged containers.

**Fix**: Use the `privileged` policy for that namespace, or add an exemption via the `privileged` label.

## Best Practices

1. **Use `restricted` for application workloads** in production.
2. **Use `baseline` for development namespaces** where some flexibility is needed.
3. **Use `privileged` only for system components** that truly need it.
4. **Always set `runAsNonRoot: true`** at the pod level for Baseline and Restricted.
5. **Always drop all capabilities** and add back only what is needed.
6. **Use PSA labels consistently** across namespaces.
7. **Audit with `kubectl describe pod`** to check effective security context values.

## Common Pitfalls

- **Forgetting `fsGroup`**: Volume permissions can silently fail without `fsGroup` in the pod-level security context.
- **Setting `runAsNonRoot` without `runAsUser`**: If the image runs as root (UID 0), `runAsNonRoot` alone will reject the pod. Add `runAsUser` with a non-zero UID.
- **Not setting `allowPrivilegeEscalation: false`**: The default is `true` if not set, which is a security risk.
- **Confusing PSS with RBAC**: PSS controls what pods can run; RBAC controls who can create/modify pods. They are independent mechanisms.
- **Assuming PSA is always enabled**: PSA is built-in and available by default in K8s 1.25+, but enforcement is opt-in via namespace labels. The default policy mode is privileged (no enforcement). Check with `ps aux | grep kube-apiserver | grep pod-security`.

## Volume Permissions and fsGroup Deep Dive

When you mount a Persistent Volume (like an AWS EBS volume, GCE Persistent Disk, or standard block storage PVC) into a Kubernetes Pod, the volume directory is typically created and mounted with root user and root group ownership by default. If you forget to define an `fsGroup` (File System Group), you create a permissions mismatch that Kubernetes will not explicitly warn you about.

### The Permissions Mismatch

Security best practices dictate that containers should run as a non-root user (e.g., `runAsUser: 1000`). However, if your application (running as user 1000) tries to write to a volume owned by `root:root`, the Linux kernel will block it. The application receives a `Permission Denied` error.

### Why the Failure is "Silent"

Kubernetes only manages the infrastructure state, not the application state.
- The Scheduler successfully finds a node.
- The Kubelet successfully attaches and mounts the volume.
- The Container Runtime successfully starts the container.

As far as Kubernetes is concerned, the Pod is completely healthy and in a `Running` state. The failure happens entirely inside your application at runtime. Your database might fail to initialize, your app might throw HTTP 500 errors, or the container might enter a `CrashLoopBackOff` state—leaving you to dig through application logs to realize it's a volume permission issue.

### How fsGroup Fixes It

When you declare an `fsGroup` in the Pod-level `securityContext`, you are instructing the Kubelet to do three things before the container even starts:
1. **Change Ownership**: It recursively runs `chgrp` on the volume, changing the group ownership of all files and directories to the `fsGroup` ID.
2. **Set Permissions**: It modifies the permissions (via the SGID bit) so that any new files created in the volume will also inherit this group ownership.
3. **Add Supplemental Group**: It adds the `fsGroup` ID to the container's list of supplemental groups, granting the container read/write access.

### The Fix (YAML Example)

To resolve this, apply the `fsGroup` at the Pod level (not the container level) so it applies to the mounted volumes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-secure-app
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000  # Kubelet will change volume group ownership to 2000
  containers:
  - name: my-app
    image: my-app-image
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: my-pvc
```

> **Expert Note**: Recursively changing permissions on a massive volume with millions of files can cause the Pod to hang in the `ContainerCreating` state for a long time. In Kubernetes 1.20+, you can add `fsGroupChangePolicy: "OnRootMismatch"` to the `securityContext`. This tells Kubelet to only run the `chgrp` operation if the top-level directory does not already match the `fsGroup`, significantly speeding up Pod startup times.

### Finding the Required fsGroup for Existing Volumes

It completely depends on whether you are creating a fresh volume or attaching to a pre-existing volume (like an existing NFS share or a hostPath).

**1. Fresh Volumes (You make the rules)**
If you are creating a brand new volume—such as an `emptyDir` or a dynamically provisioned `PersistentVolumeClaim` (PVC) via a StorageClass—you just make the number up. Pick an arbitrary, unprivileged GID (like 2000, 3000, or 10000). Because the volume is empty and managed by Kubernetes, the Kubelet will look at the `fsGroup` you chose and force the volume's permissions to match it. You dictate the group, and the volume obeys.

**2. Pre-existing Volumes (You must match the rules)**
If you are mounting storage that already exists and has data on it (like a company NFS server, a cloud file share, or a local hostPath on the node), the files already belong to a specific Linux group on that backend system. In this case, Kubernetes will not (and sometimes cannot) change the permissions on an external system. You must find out the GID of the external storage and set your `fsGroup` or `supplementalGroups` to match it.

**How to find the GID of an existing volume:**
1. Create a debug Pod running as root and mount the volume
2. Exec into the Pod: `kubectl exec -it volume-debugger -- sh`
3. List files with numeric IDs: `ls -ln /data`
4. The fourth column is the Group GID — use that value for `fsGroup`

### Multiple Groups: Primary, fsGroup, and supplementalGroups

In Linux, every user has:
- **Primary Group** (max 1): Default group for new files (`runAsGroup` in K8s)
- **Supplemental Groups** (many): Additional groups for accessing shared resources (`supplementalGroups` in K8s)

`fsGroup` is special: it automates volume ownership **and** adds itself as a supplemental group to all containers in the Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-group-pod
spec:
  securityContext:
    runAsUser: 1000          # The Linux User ID (UID)
    runAsGroup: 3000         # The Primary Group ID (GID)
    fsGroup: 2000            # Automates volume ownership & adds as supplemental group
    supplementalGroups:      # Explicit list of extra groups
      - 4000
      - 4001
  containers:
  - name: my-app
    image: my-app-image
```

At runtime: `uid=1000 gid=3000 groups=3000,2000,4000,4001`

### Sidecars and Shared Volumes

Because `fsGroup` applies at the Pod level, every container in the Pod (main app, sidecars, init containers) inherits the same supplemental group. This allows different users running in different containers to safely read/write to the same shared volume without insecure permissions like `chmod 777`.

Example:
- Main App runs as User 1000
- Sidecar (log forwarder) runs as User 999
- Shared Volume owned by `fsGroup: 2000`

Both containers get group 2000 added, so the sidecar can read logs the main app wrote.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  securityContext:
    fsGroup: 2000  # Applies to ALL containers below
  containers:
  - name: main-app
    image: my-app
    securityContext:
      runAsUser: 1000
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: sidecar-logger
    image: fluentd
    securityContext:
      runAsUser: 999
    volumeMounts:
    - name: shared-data
      mountPath: /var/log/app
  volumes:
  - name: shared-data
    emptyDir: {}
```

### Linux Underpinnings

`fsGroup` relies entirely on standard Linux POSIX file permissions, GIDs, and supplemental groups. It does nothing for Windows containers.

| Kubernetes Field | Linux Mechanism |
|------------------|-----------------|
| `fsGroup` number | Linux Group ID (GID) |
| Volume `chgrp` | `chgrp -R <gid> /mount/path` |
| Supplemental groups | Added to process credential list |
| `setgid` bit on directory | New files inherit parent directory's group |
