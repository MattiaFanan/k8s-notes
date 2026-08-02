# Storage - Imperative Commands

```bash
# Create PVC
kubectl get pvc
kubectl create -f pvc.yaml

# Describe PVC binding status
kubectl describe pvc my-pvc

# Create StorageClass
kubectl create -f storageclass.yaml

# Get PV/PVC/SC details
kubectl get pv,pvc,storageclass
```

## Common Editing
```bash
# Edit PVC storage request (editable field)
kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"5Gi"}}}}'

# Resize PVC if StorageClass allows
kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"5Gi"}}}}'
```

## Cleanup
```bash
kubectl delete pvc my-pvc
kubectl delete pv my-pv
kubectl delete storageclass fast
```

## Dry-run generation
```bash
kubectl apply -f pvc.yaml --dry-run=client -o yaml
```
