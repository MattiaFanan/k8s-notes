# PodDisruptionBudgets and Deployment Strategies

PodDisruptionBudgets (PDBs) limit the number of pods of a replicated application that are down simultaneously from voluntary disruptions. They are essential for ensuring high availability during cluster maintenance.

## What Are PodDisruptionBudgets?

A PDB specifies the minimum number or percentage of pods that must remain available during voluntary disruptions. Voluntary disruptions include:

- `kubectl drain` (node maintenance)
- Cluster upgrades
- Node maintenance events

## PDB YAML Structure

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  minAvailable: 2          # At least 2 pods must be available
  selector:
    matchLabels:
      app: my-app
```

### Using maxUnavailable Instead

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  maxUnavailable: 1        # At most 1 pod can be unavailable
  selector:
    matchLabels:
      app: my-app
```

### Using Percentage

```yaml
spec:
  minAvailable: 50%        # At least 50% of pods must be available
```

## PDB and Deployment Strategies

### PDB with RollingUpdate

When a Deployment performs a rolling update, it creates new pods before killing old ones. PDBs do not limit Deployment rolling updates; the Deployment controller manages pod replacements independently based on its own strategy settings (`maxUnavailable` and `maxSurge`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web
```

### PDB Interaction with maxUnavailable

If `minAvailable` is set to 3 and the Deployment has 3 replicas, then `maxUnavailable` must be 0. This means the rollout cannot kill any old pods until new pods are ready, which can make rollouts slower.

### PDB Interaction with Recreate Strategy

The Recreate strategy kills all pods before creating new ones. PDBs do not block the Recreate strategy because workload controllers use the Pod DELETE API directly rather than the Eviction API, which is what PDBs govern.

## PDB YAML Structure Reference

| Field | Required | Description |
|-------|----------|-------------|
| `spec.minAvailable` | One of minAvailable or maxUnavailable | Minimum pods that must be available |
| `spec.maxUnavailable` | One of minAvailable or maxUnavailable | Maximum pods that can be unavailable |
| `spec.selector` | Required | Label selector for the pods protected by the PDB |
| `spec.minAvailable` (percentage) | Alternative to integer | Percentage of pods that must be available |

## PDB Commands

```bash
# Create a PDB
kubectl create pdb my-app-pdb --min-available=2 --selector=app=my-app

# Create a PDB with maxUnavailable
kubectl create pdb my-app-pdb --max-unavailable=1 --selector=app=my-app

# Apply PDB from YAML
kubectl apply -f pdb.yaml

# Check PDB status
kubectl get pdb
kubectl describe pdb my-app-pdb

# Delete a PDB
kubectl delete pdb my-app-pdb
```

## PDB and Cluster Maintenance

When a node is drained, the kube-controller-manager checks PDBs before evicting pods:

```bash
# Drain a node (respects PDBs)
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data

# Force drain (ignores PDBs - use with caution)
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data --force --grace-period=0
```

## Exam Relevance

- PDBs are relevant to CKAD under AD-01 (deployment strategies) and OM-05 (debugging).
- Understand how PDBs interact with rolling updates.
- Know the difference between `minAvailable` and `maxUnavailable`.
- Understand that PDBs only affect voluntary disruptions, not involuntary ones (node failure, OOMKill).

## Common Pitfalls

1. **PDB blocking rollouts**: A PDB with `minAvailable` equal to `replicas` blocks any rolling update by preventing voluntary evictions during `kubectl drain`. However, the Deployment controller itself is not limited by PDBs — it uses direct Pod DELETE, not the Eviction API. The rollout proceeds normally; the issue only arises when draining nodes.
4. **Wrong selector**: The PDB selector must match the pod labels exactly.

## Best Practices

1. **Always create PDBs for production workloads** with 3+ replicas.
2. **Use `maxUnavailable` for easier rollouts**: It allows more flexibility during updates.
3. **Set `minAvailable` to `replicas - 1`** for critical workloads to ensure at least N-1 pods are always available.
4. **Test PDB behavior** in staging before applying to production.
5. **Document PDB requirements** for each application.

## See also

- [Deployment Strategies](02-deployment-strategies.md)
- [Deployments CKAD Tips](../../03-deployments/5-ckad-tips.md)