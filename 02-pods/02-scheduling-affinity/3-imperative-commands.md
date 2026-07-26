# Pods - Scheduling Affinity - Imperative Commands

```bash
# Add node label
kubectl label nodes node1 node-role.kubernetes.io/worker=""

# Describe node labels
kubectl get node node1 --show-labels
kubectl describe node node1 | grep -A10 Labels
```

## Pod Generation
```bash
kubectl run node-affinity-pod --image=nginx $do > pod.yaml
# Add affinity section to pod.yaml manually
```

## View
```bash
kubectl get pods -o wide
kubectl get nodes -L node-role.kubernetes.io/worker
```

## Remove Labels
```bash
kubectl label nodes node1 node-role.kubernetes.io/worker-
```
