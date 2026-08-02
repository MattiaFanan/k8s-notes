# DaemonSets - Imperative Commands

```bash
# Generate DaemonSet YAML
kubectl create daemonset node-logger --image=fluentbit:latest --dry-run=client -o yaml > ds.yaml

# Rolling update
kubectl rollout status daemonset node-logger
kubectl rollout history daemonset node-logger
kubectl rollout undo daemonset node-logger

# Rollout resume/pause
kubectl rollout pause daemonset node-logger
kubectl rollout resume daemonset node-logger
```

## Edit
```bash
kubectl edit daemonset node-logger
```

## Delete
```bash
kubectl delete daemonset node-logger
```

## List Pods
```bash
kubectl get pods -l app=node-logger
kubectl get daemonset
```
