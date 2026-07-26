# ConfigMaps & Secrets - CKAD Exam Tips

## Exam Shortcuts

- Use `--from-literal` for fast secret/configmap creation.
- Immediately verify with `kubectl get secret ... -o jsonpath` and `base64 --decode`.
- For multiple env vars, use `envFrom: - configMapRef:` to avoid repeating `valueFrom`.

## Pitfalls
1. **Forgetting Namespace**: ConfigMaps & Secrets are namespaced unless specified otherwise.
2. **Missing Volume Mounts**: When mounting ConfigMap files, ensure `mountPath` matches the exact expected filename.
3. **Case Sensitivity**: Keys and Secret names are case-sensitive.

## Time-Saver
```bash
alias k=kubectl
# Verify secret combo in one line
k get secret mysecret -o jsonpath='{.data.username}' | base64 -d
```
