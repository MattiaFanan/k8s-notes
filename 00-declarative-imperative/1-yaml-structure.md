# Declarative vs Imperative - Overview

Kubernetes supports two primary ways of working: imperative (command-driven) and declarative (intent-driven). Understanding when and why to use each is foundational for both real-world operations and the CKAD exam.

## Conceptual Examples

### Creating a Deployment

**Declarative (YAML first, then apply):**
```yaml
# nginx-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f nginx-deploy.yaml
```

**Imperative (single command):**
```bash
kubectl create deployment nginx --image=nginx:1.25 --replicas=3
```

### Updating a Deployment

**Declarative:**
```bash
# Edit nginx-deploy.yaml: image: nginx:1.26, replicas: 5
kubectl apply -f nginx-deploy.yaml
```

**Imperative:**
```bash
kubectl set image deployment/nginx nginx=nginx:1.26
kubectl scale deployment/nginx --replicas=5
```

### Exposing a Service

**Declarative:**
```yaml
# nginx-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

```bash
kubectl apply -f nginx-svc.yaml
```

**Imperative:**
```bash
kubectl expose deployment nginx --port=80 --target-port=80
```
