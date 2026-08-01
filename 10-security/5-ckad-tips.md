# Security Contexts & Probes - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Speed Tips
- Default secure Pod: `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities: drop: ALL`, `runAsNonRoot: true`.
- Always include `readinessProbe` in application Pods; avoid `livenessProbe` during exam unless explicitly asked (to prevent unexpected restarts).
- Use startup probes for slow-starting applications (Java, Go with large deps).
- A Pod is ALL Guaranteed or nothing: if even one container in a multi-container Pod is missing a matching request/limit pair, the entire Pod drops to Burstable.

## Pitfalls
1. **Forgetting `fsGroup`**: Volume permissions can silently fail without `fsGroup`.
2. **Never trust `readOnlyRootFilesystem` alone**: Some apps still attempt to write; mount `emptyDir` for writable paths.
3. **Resource Quotas**: Must create quota before workload; Pod creation fails if quota is exceeded.
4. **Probe timing**: `initialDelaySeconds` too short causes false liveness failures on slow-start apps.
5. **`allowPrivilegeEscalation` defaults to `true`**: Always set it explicitly to `false`.
6. **Privileged containers**: Never set `privileged: true` unless absolutely necessary.
7. **Security context at wrong level**: Pod-level security context applies to all containers; container-level overrides pod-level.

## Checklist
```bash
alias k=kubectl
# Quick security audit
k get pod -o jsonpath='{.items[*].spec.securityContext}'
```

## See also

- [Key Security Fields](2-mechanics/01-key-security-fields.md)
- [Security Context Scoping](2-mechanics/04-securitycontext-scoping.md)
- [Probe Behavior](2-mechanics/03-probes-behavior.md)
- [LimitRange and ResourceQuota](2-mechanics/02-limitrange-resourcequota.md)
