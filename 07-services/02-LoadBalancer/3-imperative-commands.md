# Services - LoadBalancer - Imperative Commands

```bash
# Create LoadBalancer service
kubectl expose deployment web --port=80 --target-port=8080 --type=LoadBalancer

# Check external IP assignment
kubectl get svc web-service -w

# Describe service details
kubectl describe svc web-service
```

## Quick Annotation
```bash
kubectl annotate svc web-service service.beta.kubernetes.io/aws-load-balancer-type=nlb
```

## Delete
```bash
kubectl delete svc web-service
```
