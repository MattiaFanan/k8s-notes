# Pods - Taints & Tolerations - Imperative Commands
%comment this page is almost useless, merge with structure
```bash
# Add taint to node
kubectl taint nodes node1 key=value:NoSchedule

# Remove taint from node
kubectl taint nodes node1 key:NoSchedule-

# Update existing taint
kubectl taint nodes node1 key=newvalue:NoSchedule --overwrite

# Describe node to see taints
kubectl describe node node1 | grep -A5 Taints
```

## Pod Generation
```bash
kubectl run tolerant-pod --image=nginx --dry-run=client -o yaml > pod.yaml
# Add tolerations to pod.yaml manually
```

## View
```bash
kubectl get pods -o wide
kubectl describe node node1
```
