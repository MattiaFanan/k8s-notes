# Helm & Kustomize - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Quick Tips
- `helm install ... --set key=value` is fast for one-liners.
- Kustomize with `kubectl apply -k` is lightweight and exam-friendly.
- Use `helm template` to preview rendered manifests without installing.
- Use `helm upgrade` to update a release and `helm rollback` to revert.
- Kustomize overlays use `patchesStrategicMerge` or `patchesJson6902` for modifications.

## Pitfalls
1. **Helm `--dry-run` not equals deploy**: Use `helm template` to preview rendered manifests exactly.
2. **Kustomize requires strict YAML**: No templating; overlays must match base resource fields.
3. **Namespace collision**: Ensure `namespace:` field is consistently set in base and overlay.
4. **Helm release name conflicts**: Use `--replace` flag if reinstalling a previously deleted release.
5. **Kustomize `kustomization.yaml` must be named exactly**: No alternative names are supported.
6. **Helm chart dependencies**: If a chart has dependencies, run `helm dependency build` before installing.

## Time-Saver
```bash
# Quick kustomize dry-run before apply
kubectl kustomize ./overlay | kubectl apply -f -

# Quick Helm template preview
helm template mychart ./chart --set replicaCount=3

# Quick Helm install with dry-run
helm install mychart ./chart --dry-run=client -o yaml

# Quick Helm upgrade
helm upgrade myrelease ./chart --set image.tag=v2

# Quick Helm rollback
helm rollback myrelease 1
```

## See also

- [Helm YAML Structure](1-yaml-structure.md)
- [Helm Mechanics](2-mechanics/03-helm.md)
- [Kustomize Mechanics](2-mechanics/04-kustomize.md)
- [Helm vs Kustomize](2-mechanics/02-helm-vs-kustomize.md)
