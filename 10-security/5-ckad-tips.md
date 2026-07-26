# Security Contexts & Probes - CKAD Exam Tips

## Exam Speed Tips
- Default secure Pod: `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities: drop: ALL`, `runAsNonRoot: true`.
- Always include `readinessProbe` in application Pods; avoid `livenessProbe` during exam unless explicitly asked (to prevent unexpected restarts).

## Pitfalls
1. **Forgetting `fsGroup`**: Volume permissions can silently fail without `fsGroup`.
2. **Never trust `readOnlyRootFilesystem` alone**: Some apps still attempt to write; mount `emptyDir` for writable paths.
3. **Resource Quotas**: Must create quota before workload; Pod creation fails if quota is exceeded.
4. **Probe timing**: `initialDelaySeconds` too short causes false liveness failures on slow-start apps.

## Checklist
```bash
alias k=kubectl
# Quick security audit
k get pod -o jsonpath='{.items[*].spec.securityContext}'
```
