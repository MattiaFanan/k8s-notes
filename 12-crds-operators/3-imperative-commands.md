# CRDs & Operators - Imperative Commands (example crontab CRD)

```bash
# Create CRD
kubectl create -f crd.yaml

# List CRDs
kubectl get crd

# Describe CRD
kubectl describe crd crontabs.stable.example.com

# Create Custom Resource
kubectl apply -f my-crontab.yaml

# List CRs
kubectl get crontab
```

## Quick CRD Generation
```bash
# Dry-run CRD creation
kubectl create -f crd.yaml --dry-run=client -o yaml
```

## Get CR Status
```bash
kubectl get crontab my-new-cron -o yaml
kubectl get crontab my-new-cron -o jsonpath='{.status}'
```

## Cleanup
```bash
kubectl delete crontab my-new-cron
kubectl delete crd crontabs.stable.example.com
```

## Inspect CRD Fields

```bash
# Explain CRD fields after applying
kubectl explain crontab
kubectl explain crontab.spec
kubectl explain crontab.spec.cronSpec
```
