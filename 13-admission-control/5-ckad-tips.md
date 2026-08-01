# Admission Control, Authentication & Authorization - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Shortcuts
- Use `kubectl create secret docker-registry` for one-line image pull secret creation.
- Patch default SA with imagePullSecret to avoid per-Pod edits.
- Use `kubectl auth can-i` to verify permissions instantly.
- Use `kubectl auth can-i --list` to audit all permissions.

```bash
kubectl patch sa default -p '{"imagePullSecrets": [{"name": "my-registry-cred"}]}'
```

## Pitfalls
1. **Forgetting CCM/CSI are out of scope**: CKAD usually abstracts cloud provider details.
2. **Webhook path/caBundle**: Typos in these fields silently prevent webhook calls.
3. **RBAC over `*`**: Overly broad roles may be too permissive, but confirm minimal sufficient access.
4. **Admission controller sideEffects**: Must be set to correct value or `None`/`NoneOnDryRun` for K8s 1.16+.
5. **PodSecurityPolicy is removed**: Use Pod Security Standards (privileged/baseline/restricted) instead.
6. **PSA labels on namespaces**: `pod-security.kubernetes.io/enforce`, `warn`, `audit` control enforcement.
7. **ImagePullSecret type must be `kubernetes.io/dockerconfigjson`**: Not `Opaque`.

## Checklist
- Always verify `ServiceAccount` exists before referencing it.
- Default SA `default` has limited permissions; check with `kubectl auth can-i`.
- Verify namespace labels for Pod Security Admission.
- Verify webhook `caBundle` is correct and the service is running.
- Check `failurePolicy` on webhooks (`Fail` for production, `Ignore` for testing).

## See also

- [Admission Controllers](2-mechanics/01-admission-controllers.md)
- [Admission Flow](2-mechanics/02-admission-flow.md)
- [Authentication](2-mechanics/03-authentication.md)
- [Authorization](2-mechanics/04-authorization.md)
- [ImagePullSecrets](2-mechanics/06-imagepullsecrets.md)
- [Pod Security Standards](../../02-pods/2-mechanics/04-security/1-yaml-structure.md)
