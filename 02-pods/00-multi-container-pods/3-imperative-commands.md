# Multi-Container Pods - Imperative Commands

```bash
# Generate basic Pod with sidecar
kubectl run main-app --image=main-app $do > pod.yaml

# Create Init Container via direct imperative command
# NOTE: Init containers cannot be added with a simple imperative run; requires editing YAML

# Difficult to add sidecars imperatively after initial creation
kubectl run logging-app --image=nginx $do --overrides='{...}'
```

## Editable Fields in Multi-Container Pods
- You can edit `spec.containers[*].image` in-place.
- `initContainers` and new containers are **NOT** editable fields on running pods.
- To add an init container or sidecar after creation, you must delete and replace the Pod, or use a Deployment controller to orchestrate changes.

## Pattern Generation Tip
```bash
# Use templated YAML and apply instead of pure imperative commands for sidecars
cat <<EOF > multi-containers.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-app
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  - name: sidecar
    image: busybox
    args: ["tail", "-f", "/var/log/nginx/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  volumes:
  - name: logs
    emptyDir: {}
EOF
kubectl apply -f multi-containers.yaml
```
