# ConfigMaps & Secrets - Imperative Commands

```bash
# Create ConfigMap from literal values
kubectl create configmap app-config --from-literal=APP_MODE=production --from-literal=DB_HOST=db

# Create ConfigMap from file
kubectl create configmap app-config --from-file=config.properties

# Create Secret from literal values (base64 encoded automatically)
kubectl create secret generic db-credentials --from-literal=username=admin --from-literal=password=s3cret

# Create Secret from file
kubectl create secret generic db-credentials --from-file=ssh-privatekey=~/.ssh/id_rsa

# Create Docker registry Secret
kubectl create secret docker-registry my-registry-key \
  --docker-server=my-registry \
  --docker-username=myuser \
  --docker-password=mypass

# View Secret data decoded
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 --decode
```

## Dry-Run Generation Pattern
```bash
kubectl create configmap app-config --from-literal=APP_MODE=production $do
```
