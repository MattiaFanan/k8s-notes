# Services - NodePort - Imperative Commands

```bash
# Create NodePort service
kubectl expose deployment web --port=80 --target-port=8080 --type=NodePort

# Create specific NodePort
kubectl expose deployment web --port=80 --target-port=8080 --type=NodePort --node-port=30080

# List NodePorts
kubectl get svc
```

## Access Test
```bash
# From outside cluster
curl http://<node-ip>:30080

# From inside cluster
kubectl run tester --image=busybox --rm -it -- wget -O- http://web-service:80
```

## Edit
```bash
kubectl edit svc web-service
```

## Delete
```bash
kubectl delete svc web-service
```
