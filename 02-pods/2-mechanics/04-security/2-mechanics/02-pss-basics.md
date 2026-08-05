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

%comment add the following somewhere where it fits, or in a new .md file
When you mount a Persistent Volume (like an AWS EBS volume, GCE Persistent Disk, or standard block storage PVC) into a Kubernetes Pod, the volume directory is typically created and mounted with root user and root group ownership by default.
If you forget to define an fsGroup (File System Group), you create a permissions mismatch that Kubernetes will not explicitly warn you about.
Here is exactly why and how this silent failure occurs.
1. The Permissions Mismatch
Security best practices dictate that containers should run as a non-root user (e.g., runAsUser: 1000). However, if your application (running as user 1000) tries to write to a volume owned by root:root, the Linux kernel will block it. The application receives a Permission Denied error.
2. Why the Failure is "Silent"
Kubernetes only manages the infrastructure state, not the application state.
 * The Scheduler successfully finds a node.
 * The Kubelet successfully attaches and mounts the volume.
 * The Container Runtime successfully starts the container.
As far as Kubernetes is concerned, the Pod is completely healthy and in a Running state. The failure happens entirely inside your application at runtime. Your database might fail to initialize, your app might throw HTTP 500 errors, or the container might enter a CrashLoopBackOff state—leaving you to dig through application logs to realize it's a volume permission issue.
3. How fsGroup Fixes It
When you declare an fsGroup in the Pod-level securityContext, you are instructing the Kubelet to do two things before the container even starts:
 * Change Ownership: It recursively runs chgrp on the volume, changing the group ownership of all files and directories to the fsGroup ID.
 * Set Permissions: It modifies the permissions (via the SGID bit) so that any new files created in the volume will also inherit this group ownership.
 * Add Supplemental Group: It adds the fsGroup ID to the container's list of supplemental groups, granting the container read/write access.
The Fix (YAML Example)
To resolve this, apply the fsGroup at the Pod level (not the container level) so it applies to the mounted volumes:
apiVersion: v1
kind: Pod
metadata:
  name: my-secure-app
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000 # Kubelet will change volume group ownership to 2000
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

> Expert Note: Recursively changing permissions on a massive volume with millions of files can cause the Pod to hang in the ContainerCreating state for a long time. In Kubernetes 1.20+, you can add fsGroupChangePolicy: "OnRootMismatch" to the securityContext. This tells Kubelet to only run the chgrp operation if the top-level directory does not already match the fsGroup, significantly speeding up Pod startup times.
> 
PersistentVolumeClaims (Storage Resources)
Used at the top of the specification to request a specific capacity of persistent storage.
 * Path: spec.resources.requests.storage
 * Controls: Persistent storage volume size.
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi

Pods (Aggregate Resources)
Traditionally, Pods do not have their own top-level resources block for CPU and memory; their total footprint is calculated by summing the individual container requirements. However, newer Kubernetes versions introduce Pod-level spec.resources and spec.resourceClaims for specialized hardware like GPUs.
2. Node Affinity and Pod Affinity
Kubernetes provides advanced scheduling features via Node Affinity and Pod Affinity/Anti-Affinity.
Node Affinity (Pod to Node)
Constrains which nodes your Pod can run on based on node labels.
 * Hard Rule (requiredDuringSchedulingIgnoredDuringExecution): Must be met; otherwise, the Pod remains Pending.
 * Soft Rule (preferredDuringSchedulingIgnoredDuringExecution): Preferred, but the scheduler will fall back to other nodes if necessary.
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values:
          - us-east-1a

Pod Affinity and Anti-Affinity (Pod to Pod)
Constrains scheduling based on the labels of other Pods already running on a node.
 * Pod Affinity: Attracts Pods to run together (e.g., placing a web app near a cache to lower latency).
 * Pod Anti-Affinity: Repels Pods to ensure high availability (e.g., spreading replicas across separate nodes).
3. Negative Selectors in Node Affinity
Node Affinity supports negative selection using specific operators within matchExpressions:
 * NotIn: Matches if the label key exists but its value is not in the provided list (or if the label is missing entirely).
 * DoesNotExist: Strictly checks that the node does not have the specified label key at all (useful for maintenance modes or isolating specialized node pools).
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: maintenance-mode
          operator: DoesNotExist

4. Why nodeSelectorTerms is a List vs. labelSelector
Question: Why is nodeSelectorTerms a list in Node Affinity, while labelSelector is a single object in Pod Affinity?
Answer: The structural difference exists because of how Kubernetes handles logical OR conditions and how Pod Affinity relies on a topologyKey.
Node Affinity: The Selectors are the List
nodeSelectorTerms is an array. Kubernetes evaluates multiple terms in this list using OR logic. Inside each term, expressions use AND logic.
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions: # TERM 1: Schedule here...
      - key: gpu
        operator: Exists
    - matchExpressions: # OR TERM 2: ...or schedule here
      - key: disk
        operator: In
        values: [ssd]

Pod Affinity: The Terms are the List
A labelSelector is a single object. To create an OR condition, the parent field (requiredDuringSchedulingIgnoredDuringExecution) acts as the list containing multiple PodAffinityTerm objects. This is required because each labelSelector must be tightly coupled with its own topologyKey (defining the boundary like node, rack, or zone).
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions: 
      - key: app
        operator: In
        values: [web]
    topologyKey: kubernetes.io/hostname
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values: [cache]
    topologyKey: topology.kubernetes.io/zone

5. Volume Permissions and fsGroup
When mounting a Persistent Volume, the directory is typically created with root user and root group ownership. If your container runs as a non-root user (e.g., runAsUser: 1000), it will experience a Permission Denied error.
Why the Failure is "Silent"
Kubernetes successfully attaches the volume and boots the container, placing it in a healthy Running state. The failure happens entirely inside your application at runtime.
How fsGroup Fixes It
When defined in a Pod's securityContext, fsGroup instructs the Kubelet to:
 * Recursively run chgrp on the volume to change group ownership.
 * Apply the SGID bit so new files inherit the group.
 * Add the group ID to the container process's supplemental groups.
apiVersion: v1
kind: Pod
metadata:
  name: my-secure-app
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 2000 # Kubelet changes volume group ownership to 2000
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

6. Linux Underpinnings: Groups and Sidecars
Is fsGroup a Linux thing?
Yes. It relies entirely on standard Linux POSIX file permissions, group IDs (GIDs), and supplemental groups. It does nothing for Windows containers.
Sidecars and Shared Volumes
Because fsGroup applies at the Pod level, every container in the Pod (main app and sidecars) inherits the same supplemental group. This allows different users running inside different containers to safely read and write to the same shared volume without resorting to insecure permissions like chmod 777.
Managing Multiple Groups
Linux users can belong to a primary group (runAsGroup) and multiple secondary groups (supplementalGroups), granting flexible access across multiple system resources or mounted volumes.
Finding the Required fsGroup for Existing Volumes
 * Fresh Volumes: You can choose any arbitrary unprivileged GID (e.g., 2000).
 * Pre-existing Volumes: If mounting external storage with pre-existing data, deploy a temporary debug Pod running as root, exec into it, and inspect file permissions using ls -ln /data to find the exact GID required.
   """
with open("kubernetes_resources_affinity_permissions_chat.md", "w") as f:
f.write(chat_content)

Your markdown file is ready
[file-tag: code-generated-file-33ff1958-42b7-4cb0-a444-c225d8faff3f]

The complete chat session has been compiled into a well-structured, formatted Markdown document (`kubernetes_resources_affinity_permissions_chat.md`), covering everything from Kubernetes resource fields, node and pod affinities, logical operators, and Linux volume permissions (`fsGroup`).
