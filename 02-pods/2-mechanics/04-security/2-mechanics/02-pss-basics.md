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
- Read-only root filesystem recommended

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

### PSA Hierarchy

PSA uses a hierarchy of policies. When a namespace has a label, it inherits from the closest ancestor that has a label.

```
cluster (no label)
└── namespace-a (enforce=baseline)
    └── namespace-b (no label) → inherits baseline from namespace-a
```

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
- **Assuming PSA is always enabled**: PSA must be explicitly enabled in the kube-apiserver configuration. Check with `ps aux | grep kube-apiserver | grep pod-security`.