# Services - Ingress - Imperative Commands

```bash
# Create Ingress
kubectl create ingress web-ingress --class=nginx \
  --rule="myapp.example.com/*=web-service:80"

# Describe Ingress
kubectl describe ingress web-ingress

# Get Ingress addresses
kubectl get ingress
```

## Quick SVG
```bash
kubectl create ingress api-ingress --class=nginx \
  --rule="api.example.com/api/*=api-service:8080"
```

## Delete
```bash
kubectl delete ingress web-ingress
```
