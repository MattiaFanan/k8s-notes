# Helm & Kustomize - CKAD Exam Tips

## Exam Quick Tips
- `helm install ... --set key=value` is fast for one-liners.
- Kustomize with `kubectl apply -k` is lightweight and exam-friendly.

## Pitfalls
1. **Helm `--dry-run` not equals deploy**: Use `helm template` to preview rendered manifests exactly.
2. **Kustomize requires strict YAML**: No templating; overlays must match base resource fields.
3. **Namespace collision**: Ensure `namespace:` field is consistently set in base and overlay.

## Time-Saver
```bash
# Quick kustomize dry-run before apply
kubectl kustomize ./overlay | kubectl apply -f -
```
