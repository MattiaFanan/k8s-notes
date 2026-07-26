# Declarative vs Imperative - Imperative Commands

## Creation

```bash
# Imperative create (fails if object exists)
kubectl create deployment nginx --image=nginx:1.25 --replicas=3
kubectl create service clusterip nginx --tcp=80:80
kubectl create configmap app-config --from-literal=APP_MODE=production

# Imperative expose
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
```

## Updates

```bash
# Scale
kubectl scale deployment/nginx --replicas=5

# Set image
kubectl set image deployment/nginx nginx=nginx:1.26

# Set env from configmap
kubectl set env deployment/nginx APP_MODE=production

# Set resources
kubectl set resources deployment/nginx -c=nginx --limits=cpu=200m,memory=256Mi
```

## Dry-Run to Manifest

```bash
# Convert imperative to declarative (dry-run)
kubectl create deployment nginx --image=nginx:1.25 --replicas=3 --dry-run=client -o yaml > nginx.yaml
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > nginx-svc.yaml
```

## Edit Live Object

```bash
# Edit running object (opens editor)
kubectl edit deployment nginx
kubectl edit pod mypod
```

## Patch (Partial Update)

```bash
# Strategic merge patch
kubectl patch deployment nginx --type='json' -p='[{"op": "replace", "path": "/spec/replicas", "value":5}]'

# Simple merge patch
kubectl patch deployment nginx -p '{"spec":{"replicas": 5}}'
```
