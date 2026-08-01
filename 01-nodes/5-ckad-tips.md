# Kubernetes Nodes - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- `kubectl get nodes -o wide` shows OS, kernel, container runtime version.
- `kubectl top node` requires metrics-server but shows resource usage quickly.

## Pitfalls
1. **Cordon vs Drain**: `cordon` prevents new scheduling; `drain` evicts existing Pods.
2. **NodeSelector vs Affinity**: NodeSelector is simple equality; affinity supports richer operators.
3. **Taints repel by default**: Node tainted without toleration = Pods won't schedule.

## Kubeconfig Tips
- Before editing the kubeconfig, copy it as a backup: `cp ~/.kube/config ~/.kube/config.bak`
- To verify the kubeconfig after changes: `kubectl config view`
- The kubeconfig is freshly read at every `kubectl` command, so it doesn't need to be reloaded — changes take effect immediately.
- If you switch context, `kubectl` itself may be slow on the first run — it has to do a fresh TLS handshake to the new cluster and/or mint a new token via an exec-based credential plugin. Either pre-authenticate before switching (e.g. `aws sso login` or `gcloud auth login`) or just wait until it works again. `kubectl get nodes` is the fast test to confirm it's ready. Use `kubectl get nodes -v=6` to see where the delay is coming from.

## Time-Saver
```bash
alias k=kubectl

# Node resource snapshot
k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'
```

## See also

- [Node YAML Structure](1-yaml-structure.md)
- [Node Components](2-mechanics/02-node-components.md)
- [Node Conditions](2-mechanics/03-node-conditions.md)
- [Kubeconfig](2-mechanics/06-kubeconfig.md)
