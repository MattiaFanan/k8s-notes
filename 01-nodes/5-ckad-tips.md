# Kubernetes Nodes - CKAD Exam Tips

## Shortcuts
- `kubectl get nodes -o wide` shows OS, kernel, container runtime version.
- `kubectl top node` requires metrics-server but shows resource usage quickly.

## Pitfalls
1. **Cordon vs Drain**: `cordon` prevents new scheduling; `drain` evicts existing Pods.
2. **NodeSelector vs Affinity**: NodeSelector is simple equality; affinity supports richer operators.
3. **Taints repel by default**: Node tainted without toleration = Pods won't schedule.

## Time-Saver
```bash
alias k=kubectl

# Node resource snapshot
k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\t"}{.status.capacity.memory}{"\n"}{end}'
```
