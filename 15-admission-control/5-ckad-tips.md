# Admission Control, Authentication & Authorization - CKAD Exam Tips

## Exam Shortcuts
- Use `kubectl create secret docker-registry` for one-line image pull secret creation.
- Patch default SA with imagePullSecret to avoid per-Pod edits.

```bash
kubectl patch sa default -p '{"imagePullSecrets": [{"name": "my-registry-cred"}]}'
```

## Pitfalls
1. **Forgetting CCM/CSI are out of scope**: CKAD usually abstracts cloud provider details.
2. **Webhook path/caBundle**: Typos in these fields silently prevent webhook calls.
3. **RBAC over `*`**: Overly broad roles may be too permissive, but confirm minimal sufficient access.
4. **Admission controller sideEffects**: Must be set to correct value or `None`/`NoneOnDryRun` for K8s 1.16+.

## Checklist
- Always verify `ServiceAccount` exists before referencing it.
- Default SA `default` has limited permissions; check with `kubectl auth can-i`.
- Verify namespace labels for Pod Security Admission.
