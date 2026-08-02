# ConfigMaps & Secrets - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Shortcuts

- Use `--from-literal` for fast secret/configmap creation.
- Immediately verify with `kubectl get secret ... -o jsonpath` and `base64 --decode`.
- For multiple env vars, use `envFrom: - configMapRef:` to avoid repeating `valueFrom`.
- Use `stringData` for Secrets to write plain-text values; Kubernetes auto-encodes them.
- Use `kubectl get configmap <name> -o yaml` to verify ConfigMap contents.
- Use `kubectl get secret <name> -o jsonpath='{.data}' | jq` to verify Secret contents (values are base64).

## Pitfalls

1. **Forgetting Namespace**: ConfigMaps & Secrets are namespaced unless specified otherwise.
2. **Missing Volume Mounts**: When mounting ConfigMap files, ensure `mountPath` matches the exact expected filename.
3. **Case Sensitivity**: Keys and Secret names are case-sensitive.
4. **`data` vs `stringData`**: `data` requires base64-encoded values for Secrets; `stringData` accepts plain text. They are mutually exclusive for the same key.
5. **Immutable Secrets**: If `immutable: true` is set, the Secret cannot be updated. You must delete and recreate it.
6. **ConfigMap as env vs volume**: `env` references individual keys; `envFrom` loads all keys. Volume mounts create files with key names as filenames.

## Time-Saver

```bash
alias k=kubectl

# Quick ConfigMap dry-run generation
k create configmap app-config --from-literal=APP_MODE=production --dry-run=client -o yaml

# Quick Secret creation
k create secret generic db-creds --from-literal=username=admin --from-literal=password=s3cret

# Verify secret combo in one line
k get secret mysecret -o jsonpath='{.data.username}' | base64 -d

# Mount ConfigMap as env vars (all keys at once)
envFrom:
- configMapRef:
    name: app-config
```

## See also

- [ConfigMaps & Secrets YAML Structure](1-yaml-structure.md)
- [ConfigMap Behavior](2-mechanics/02-configmap-behavior.md)
- [Secret Behavior](2-mechanics/03-secret-behavior.md)
