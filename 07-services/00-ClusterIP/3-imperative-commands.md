# Services - ClusterIP - Imperative Commands

```bash
# Create Service with automatic selector from Deployment
kubectl expose deployment web --port=80 --target-port=8080

# Create Service manually
kubectl create service clusterip web-svc --tcp=80:8080

# Get services
kubectl get svc
kubectl describe svc web-service

# Get Endpoints
kubectl get endpoints web-service
kubectl describe endpoints web-service
```

## DNS Test
```bash
kubectl run tester --image=busybox --restart=Never --rm -it -- nslookup web-service
kubectl run tester --image=busybox --restart=Never --rm -it -- wget -O- http://web-service:80
```

## Patch / Replace
```bash
kubectl patch svc web-service -p '{"spec":{"selector":{"app":"web"}}}'
```

## Delete
```bash
kubectl delete svc web-service
```
