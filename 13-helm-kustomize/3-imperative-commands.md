# Helm & Kustomize - Imperative Commands

## Helm

```bash
# Search and add repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repos
helm repo update

# Install chart
helm install my-release bitnami/nginx

# List releases
helm list

# Upgrade release
helm upgrade my-release bitnami/nginx --set image.tag=1.26

# Get values
helm get values my-release

# Rollback
helm rollback my-release 1

# Uninstall
helm uninstall my-release

# Show rendered template
helm template my-release ./mychart
```

## Kustomize

```bash
# Apply with kubectl
kubectl apply -k ./overlay/prod

# Build output only
kubectl kustomize ./overlay/prod

# List kustoms
tree kustomization.yaml
```

## Common Patterns
```bash
# Helm value override file
helm install my-app ./chart -f values-prod.yaml

# Kustomize image update
kustomize edit set image nginx=nginx:1.26
```
