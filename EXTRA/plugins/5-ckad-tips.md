# Plugins - CKAD Exam Tips

## Exam Shortcuts

- Know which CNI plugin is running: `kubectl get pods -n kube-system | grep -E 'calico|cilium|weave|flannel|kube-router'`
- Check if NetworkPolicy is enforced by the CNI: `kubectl get pods -n kube-system -l <cnì-label>`
- Verify storage plugin quickly: `kubectl get storageclass <sc-name> -o jsonpath='{.provisioner}'`
- kubectl plugin discovery: `kubectl plugin list --name-only | head -20`

## Pitfalls

1. **Assuming NetworkPolicy works without a CNI that enforces it**: Flannel does not enforce NetworkPolicies. Calico, Cilium, and Antrea do.
2. **In-tree provisioner vs CSI mismatch**: A StorageClass using `kubernetes.io/aws-ebs` requires the in-tree cloud provider; modern clusters use `ebs.csi.aws.com`.
3. **Webhook caBundle mismatch**: If you recreate a webhook service, the `caBundle` may become stale and cause `failed calling webhook`.
4. **CSI migration is automatic**: Since Kubernetes 1.25, CSI migration is enabled by default and the `CSIMigration` feature gates were removed in v1.27.
5. **Plugin binary not in PATH**: `kubectl plugin list` is the fastest way to verify plugin visibility in the exam environment.

## Time-Saver

```bash
# Quick plugin environment audit
echo "=== CNI ==="
kubectl get pods -n kube-system -l k8s-app=calico-node 2>/dev/null || \
kubectl get pods -n kube-system -l app=cilium 2>/dev/null || echo "CNI unknown"

echo "=== Storage Provisioner ==="
kubectl get storageclass -o jsonpath='{range .items[*]}{.metadata.name}: {.provisioner}{"\n"}{end}'

echo "=== kubectl Plugins ==="
kubectl plugin list --name-only 2>/dev/null | head -10
```

## kubectl Plugin Best Practices

1. **Use Krew for management**: Krew handles installation, upgrades, and PATH setup.
2. **Pin plugin versions**: Production environments should pin plugin versions to avoid unexpected breakage.
3. **Avoid duplicate plugins**: Ensure only one `kubectl-<name>` exists in `PATH` to prevent ambiguity.
4. **Validate plugins**: Only install plugins from trusted sources. Plugins execute with your kubectl credentials.
5. **Keep plugins updated**: Run `kubectl krew upgrade` regularly to get bug fixes and new features.
