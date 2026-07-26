# Kubernetes Nodes - Imperative Commands

```bash
# List nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe node (capacity, allocatable, taints, conditions)
kubectl describe node node-1

# Add label
kubectl label nodes node-1 disktype=ssd

# Add taint
kubectl taint nodes node-1 key=value:NoSchedule

# Remove taint
kubectl taint nodes node-1 key:NoSchedule-

# Cordoning (mark unschedulable)
kubectl cordon node-1

# Draining (evict Pods gracefully)
kubectl drain node-1 --ignore-daemonsets --force --delete-emptydir-data

# Uncordon
kubectl uncordon node-1
```

## Quick Info
```bash
# Resource summary
kubectl top node
kubectl get node -o jsonpath='{.items[0].status.capacity}'
kubectl get node -o jsonpath='{.items[0].status.allocatable}'
```
