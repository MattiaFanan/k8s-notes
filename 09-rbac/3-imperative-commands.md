# RBAC & ServiceAccounts - Imperative Commands

```bash
# Create ServiceAccount
kubectl create serviceaccount my-sa -n default

# Create Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n default

# Create RoleBinding
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=default:my-sa -n default

# Create ClusterRole
kubectl create clusterrole secret-reader --verb=get,list,watch --resource=secrets

# Create ClusterRoleBinding
kubectl create clusterrolebinding read-secrets --clusterrole=secret-reader --serviceaccount=default:my-sa
```

## Dry-run generation
```bash
kubectl create role my-role --verb=get --resource=pods --dry-run=client -o yaml
kubectl create rolebinding my-rb --role=my-role --serviceaccount=default:my-sa -n default
```

## Edit & Audit
```bash
kubectl edit role pod-reader -n default
kubectl get rolebinding -n default
kubectl describe clusterrolebinding read-secrets
```

## Delete
```bash
kubectl delete serviceaccount my-sa -n default
kubectl delete role pod-reader -n default
kubectl delete rolebinding read-pods -n default
kubectl delete clusterrole secret-reader
kubectl delete clusterrolebinding read-secrets
```
