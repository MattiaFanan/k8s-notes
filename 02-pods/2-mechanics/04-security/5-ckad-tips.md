# Security Contexts, Probes & Pod Security Standards — CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Speed Tips

- Default secure Pod: `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities: drop: ALL`, `runAsNonRoot: true`.
- Always include `readinessProbe` in application Pods; avoid `livenessProbe` during exam unless explicitly asked (to prevent unexpected restarts).
- Use startup probes for slow-starting applications (Java, Go with large deps).
- A Pod is ALL Guaranteed or nothing: if even one container in a multi-container Pod is missing a matching request/limit pair, the entire Pod drops to Burstable.
- Pod Security Standards replaced PodSecurityPolicy (removed in K8s 1.25).
- PSS are enforced via namespace labels, not admission plugin configuration.
- Three policies: `privileged`, `baseline`, `restricted`.

## Key Facts for the Exam

1. **`restricted`** requires: `runAsNonRoot: true`, `runAsUser` non-zero, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities: { drop: ["ALL"] }`, no privileged containers.
2. **`baseline`** requires: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, no privileged containers.
3. **`privileged`** has no restrictions.
4. PSS labels: `pod-security.kubernetes.io/enforce`, `pod-security.kubernetes.io/warn`, `pod-security.kubernetes.io/audit`.
5. Unlabeled namespaces inherit from the closest labeled ancestor.
6. PSA is built-in and available by default in K8s 1.25+, but enforcement is opt-in via namespace labels. The default policy mode is privileged (no enforcement).

## Pitfalls

1. **Forgetting `fsGroup`**: Volume permissions fail silently without `fsGroup` in the pod-level security context.
2. **Never trust `readOnlyRootFilesystem` alone**: Some apps still attempt to write; mount `emptyDir` for writable paths.
3. **Resource Quotas**: Must create quota before workload; Pod creation fails if quota is exceeded.
4. **Probe timing**: `initialDelaySeconds` too short causes false liveness failures on slow-start apps.
5. **`allowPrivilegeEscalation` defaults to `true`**: Always set it explicitly to `false`.
6. **Privileged containers**: Never set `privileged: true` unless absolutely necessary.
7. **Security context at wrong level**: Pod-level security context applies to all containers; container-level overrides pod-level.
8. **Confusing PSS with RBAC**: PSS controls what pods can run; RBAC controls who can create/modify pods. They are independent.
9. **Setting `runAsNonRoot` without `runAsUser`**: If the image runs as root (UID 0), `runAsNonRoot` alone rejects the pod. Add `runAsUser` with a non-zero UID.
10. **Assuming PSA is always enabled**: PSA must be explicitly enabled in the kube-apiserver configuration.

## Checklist

```bash
alias k=kubectl
# Quick security audit
k get pod -o jsonpath='{.items[*].spec.securityContext}'

# Quick PSS label check
kubectl get ns --show-labels | grep pod-security

# Quick PSS enforcement test
kubectl run test-pod --image=nginx --privileged -n myns 2>&1 | grep -i "pod-security\|denied\|forbidden"
```

## See also

- [Key Security Fields](./2-mechanics/01-key-security-fields.md)
- [Security Context Scoping](./2-mechanics/06-securitycontext-scoping.md)
- [Probe Behavior](./2-mechanics/05-probes-behavior.md)
- [LimitRange and ResourceQuota](./2-mechanics/03-limitrange-resourcequota.md)
- [Admission Controllers](../../../13-admission-control/2-mechanics/01-admission-controllers.md)
