# Services - ExternalName - Imperative Commands

```bash
# Create ExternalName service
kubectl create service externalname my-db-service --external-name=mydb.example.com

# Verify DNS
kubectl run tester --image=busybox --restart=Never --rm -it -- nslookup my-db-service
```

## Delete
```bash
kubectl delete svc my-db-service
```
