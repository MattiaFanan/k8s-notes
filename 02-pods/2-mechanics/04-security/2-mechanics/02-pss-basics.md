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

Ok but how do i know the required fsgroup to write on the volume
It completely depends on whether you are creating a fresh volume or attaching to a pre-existing volume (like an existing NFS share or a hostPath).
Here is how you handle both scenarios:
1. Fresh Volumes (You make the rules)
If you are creating a brand new volume—such as an emptyDir or a dynamically provisioned PersistentVolumeClaim (PVC) via a StorageClass—you just make the number up.
Pick an arbitrary, unprivileged GID (like 2000, 3000, or 10000). Because the volume is empty and managed by Kubernetes, the Kubelet will look at the fsGroup you chose and force the volume's permissions to match it. You dictate the group, and the volume obeys.
2. Pre-existing Volumes (You must match the rules)
If you are mounting storage that already exists and has data on it (like a company NFS server, a cloud file share, or a local hostPath on the node), the files already belong to a specific Linux group on that backend system.
In this case, Kubernetes will not (and sometimes cannot) change the permissions on an external system. You must find out the GID of the external storage and set your fsGroup or supplementalGroups to match it.
How to find the GID of an existing volume
If you don't know the GID of your existing storage, the easiest way to find out is to mount it to a temporary "debug" Pod running as root, and inspect the files.
Step 1: Create a debug Pod
Apply this YAML, replacing your-existing-pvc with the name of your PVC:
apiVersion: v1
kind: Pod
metadata:
  name: volume-debugger
spec:
  containers:
  - name: debugger
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: target-volume
      mountPath: /data
  volumes:
  - name: target-volume
    persistentVolumeClaim:
      claimName: your-existing-pvc

Step 2: Exec into the Pod and check the numbers
Run the following command to get an interactive shell inside the debug Pod:
kubectl exec -it volume-debugger -- sh

Inside the shell, list the files using the -n flag (which forces Linux to show the raw numeric IDs instead of the text names):
ls -ln /data

Step 3: Read the output
You will see output that looks like this:
drwxrwx--- 2 1000 5050 4096 Aug 6 12:00 my-database-files

In Linux permissions (User Group Size Date Name), the third column is the Owner UID (1000) and the fourth column is the Group GID (5050).
Now you know the required group. You can delete the debug Pod, go to your real application's YAML, and set fsGroup: 5050.

Can a user have more gro7ps?
Yes, absolutely. In Linux (and by extension, Kubernetes), a user can belong to multiple groups simultaneously.
Here is how the Linux group system is structured and how you can configure it in Kubernetes.
1. Primary vs. Supplemental Groups in Linux
In Linux, every user account is associated with two types of groups:
 * Primary Group (Max 1): Every user must have exactly one primary group. When a user creates a new file, the file's group ownership defaults to this primary group.
 * Supplemental Groups (Many): A user can belong to dozens of additional "supplemental" (or secondary) groups. This allows the user to access files owned by any of those groups, giving administrators fine-grained control over shared resources.
2. How to Add Multiple Groups in Kubernetes
Kubernetes gives you direct control over these Linux concepts through the Pod's securityContext.
If your container process needs to access various files owned by different groups (e.g., one volume for logs, one for a database socket, and another for a shared cache), you can assign multiple groups using the supplementalGroups array.
Here is how all the group settings map together in a Pod specification:
apiVersion: v1
kind: Pod
metadata:
  name: multi-group-pod
spec:
  securityContext:
    runAsUser: 1000          # The Linux User ID (UID)
    runAsGroup: 3000         # The Primary Group ID (GID)
    fsGroup: 2000            # Automates volume ownership & adds as a supplemental group
    supplementalGroups:      # Explicit list of extra groups the user belongs to
      - 4000
      - 4001
  containers:
  - name: my-app
    image: my-app-image

What Happens at Runtime?
If you ran the id command inside that container, the Linux kernel would output something like this:
uid=1000 gid=3000 groups=3000,2000,4000,4001
Because of those supplemental groups, the container user (1000) now has permission to read and write to any file on the system or mounted volumes owned by groups 3000, 2000, 4000, or 4001.

You don't actually have to set it for both, because fsGroup is strictly a Pod-level setting, not a container-level setting.
When you define an fsGroup in the Pod's spec.securityContext, Kubernetes automatically applies that exact same supplemental group to every single container inside the Pod—including your main app, your sidecar, and any init containers.
This is actually one of the primary ways Kubernetes enables sidecar patterns.
Why This is Highly Useful for Sidecars
Sidecars often need to share data with the main container using a shared volume (like an emptyDir). Because both containers inherit the same fsGroup, they can both read and write to that shared volume seamlessly, even if they are running as completely different users.
For example:
 * Your Main App runs as User 1000.
 * Your Sidecar (e.g., a log forwarder) runs as User 999.
 * The Shared Volume is owned by fsGroup: 2000.
Because Kubernetes adds group 2000 to both containers' processes, the sidecar can read the logs the main app just wrote, without any "Permission Denied" errors.
The YAML Structure
Notice how fsGroup sits outside the containers array, governing everything inside the Pod:
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  securityContext:
    fsGroup: 2000 # Applies to ALL containers below
  containers:
  - name: main-app
    image: my-app
    securityContext:
      runAsUser: 1000 # Primary user
    volumeMounts:
    - name: shared-data
      mountPath: /data

  - name: sidecar-logger
    image: fluentd
    securityContext:
      runAsUser: 999  # Different primary user
    volumeMounts:
    - name: shared-data
      mountPath: /var/log/app

  volumes:
  - name: shared-data
    emptyDir: {}

Yes. While fsGroup itself is a Kubernetes configuration field, everything it does under the hood relies entirely on standard Linux filesystem permissions and user management.
If you are running Windows containers in Kubernetes, fsGroup does absolutely nothing. It is strictly tied to Linux and POSIX-compliant filesystems.
Here is how the Kubernetes fsGroup command maps directly to core Linux mechanics:
1. GIDs (Group IDs)
The number you assign to fsGroup (e.g., 2000) translates directly to a Linux Group ID (GID). Kubernetes passes this integer directly to the container runtime and the Linux kernel.
2. The chgrp Command
When the Kubelet attaches your volume to the node, it runs the equivalent of a recursive Linux change-group command (chgrp -R 2000 /your/mount/path). It traverses the volume and rewrites the group ownership of the files from root to your specific GID.
3. Supplemental Groups
In Linux, a user has a primary group but can also belong to multiple "supplemental" groups. Kubernetes uses this exact Linux feature. When it starts your container process, it dynamically adds the fsGroup ID to the process's list of supplemental groups. This is how your application (even if it is running as user 1000) gets permission to modify files owned by group 2000.
4. The setgid Bit
To ensure your application doesn't run into permission errors when creating new files later, Kubernetes leverages a special Linux permission called the setgid (Set Group ID) bit.
In Linux, when you apply the setgid bit to a directory, any new file created inside that directory automatically inherits the group ownership of the parent directory (your fsGroup), rather than defaulting to the primary group of the user who created the file.
In short: fsGroup is simply the Kubernetes API's way of automating traditional Linux file permission commands across dynamic, distributed storage volumes.
