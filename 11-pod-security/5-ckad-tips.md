# Pod Security Standards — CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Shortcuts

- Pod Security Standards replaced PodSecurityPolicy (removed in K8s 1.25).
- PSS are enforced via namespace labels, not admission plugin configuration.
- Three policies: `privileged`, `baseline`, `restricted`.

## Key Facts for the Exam

1. **`restricted`** requires: `runAsNonRoot: true`, `runAsUser` non-zero, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities: { drop: ["ALL"] }`, no privileged containers.
2. **`baseline`** requires: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, no privileged containers.
3. **`privileged`** has no restrictions.
4. PSS labels: `pod-security.kubernetes.io/enforce`, `pod-security.kubernetes.io/warn`, `pod-security.kubernetes.io/audit`.
5. Unlabeled namespaces inherit from the closest labeled ancestor.
6. PSA is enabled by default in K8s 1.25+.

## Pitfalls

1. **Confusing PSS with RBAC**: PSS controls what pods can run; RBAC controls who can create/modify pods. They are independent.
2. **Forgetting `fsGroup`**: Volume permissions fail silently without `fsGroup` in the pod-level security context.
3. **Setting `runAsNonRoot` without `runAsUser`**: If the image runs as root (UID 0), `runAsNonRoot` alone rejects the pod. Add `runAsUser` with a non-zero UID.
4. **Not setting `allowPrivilegeEscalation: false`**: The default is `true` if not set, which is a security risk.
5. **Assuming PSA is always enabled**: PSA must be explicitly enabled in the kube-apiserver configuration.

## Time-Saver

```bash
# Quick PSS label check
kubectl get ns --show-labels | grep pod-security

# Quick PSS enforcement test
kubectl run test-pod --image=nginx --privileged -n myns 2>&1 | grep -i "pod-security\|denied\|forbidden"
```

## See also

- [Security Context Fields](../../10-security/2-mechanics/01-key-security-fields.md)
- [Security Context Scoping](../../10-security/2-mechanics/04-securitycontext-scoping.md)
- [Admission Controllers](../../15-admission-control/2-mechanics/01-admission-controllers.md)