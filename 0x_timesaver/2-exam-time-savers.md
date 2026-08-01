# Exam Time-Savers — CKAD

> **CKAD Exam Version**: Kubernetes v1.35

## Environment Setup (add to `~/.bashrc`)

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
```

## Universal Workflow

1. Read the task carefully. Identify the resource type and namespace.
2. Use `--dry-run=client -o yaml` to scaffold if unsure of syntax.
3. Edit the YAML.
4. Apply with `kubectl apply -f`.
5. Verify with `kubectl get` and `kubectl describe`.

## Quick Decision Table

| Scenario | Command Pattern |
|----------|-----------------|
| Need a quick pod | `k run` or `kubectl create deployment --dry-run=client -o yaml` |
| Need a service | `kubectl expose` or write YAML |
| Need a configmap | `kubectl create configmap --from-literal` or `--from-file` |
| Need a secret | `kubectl create secret generic --from-literal` or `docker-registry` |
| Need a deployment | `kubectl create deployment` or write YAML |
| Need to update an image | `kubectl set image` |
| Need to scale | `kubectl scale` |
| Need to edit live | `kubectl edit` |
| Need to patch | `kubectl patch` |
| Need to verify permissions | `kubectl auth can-i` |
| Need to check DNS | `kubectl exec` into pod and run `nslookup` or `curl` |
| Need to check connectivity | `kubectl exec` into pod and run `curl` or `wget` |
| Need to debug a pod | `kubectl debug` with ephemeral container |
| Need to check rollout status | `kubectl rollout status` |
| Need to rollback a deployment | `kubectl rollout undo` |
| Need to check API version | `kubectl api-versions` |
| Need to convert deprecated APIs | `kubectl convert` |

## Namespace Discipline

- **Always** check if the task specifies a namespace. If not, use the default namespace or the one specified in the current context.
- **Always** use `-n <namespace>` explicitly, even for `default`.
- **Never** assume the namespace from a previous task carries over.

## Common Exam Patterns

### Create a deployment with 3 replicas
```bash
kubectl create deployment web --image=nginx:1.25 --replicas=3 -n myns
```

### Expose a deployment on port 80
```bash
kubectl expose deployment web --port=80 --target-port=8080 -n myns
```

### Create a configmap from a file
```bash
kubectl create configmap app-config --from-file=config.properties -n myns
```

### Mount a configmap as a volume
```yaml
volumes:
- name: config
  configMap:
    name: app-config
volumeMounts:
- name: config
  mountPath: /etc/config
```

### Create a secret from literals
```bash
kubectl create secret generic db-creds --from-literal=username=admin --from-literal=password=secret -n myns
```

### Mount a secret as a volume
```yaml
volumes:
- name: secret
  secret:
    secretName: db-creds
volumeMounts:
- name: secret
  mountPath: /etc/secret
```

### Default-deny ingress NetworkPolicy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: myns
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### Allow ingress from a specific namespace
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
  namespace: myns
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
```

### Create a ServiceAccount and bind it to a Role
```bash
kubectl create serviceaccount my-sa -n myns
kubectl create role my-role --verb=get,list,watch --resource=pods -n myns
kubectl create rolebinding my-binding --role=my-role --serviceaccount=myns:my-sa -n myns
```

### Verify a ServiceAccount can perform an action
```bash
kubectl auth can-i get pods --as=system:serviceaccount:myns:my-sa -n myns
```

### Create an Ingress
```bash
kubectl create ingress web-ingress --class=nginx --rule="myapp.example.com/*=web-service:80" -n myns
```

### Debug a pod with an ephemeral container
```bash
kubectl debug mypod -n myns --image=busybox --target=app -it -- sh
```

### Check rollout status and history
```bash
kubectl rollout status deployment/my-dep -n myns
kubectl rollout history deployment/my-dep -n myns
```

### Rollback a deployment
```bash
kubectl rollout undo deployment/my-dep -n myns
kubectl rollout undo deployment/my-dep -n myns --to-revision=2
```

### Check for deprecated APIs
```bash
kubectl apply --dry-run=server -f manifest.yaml 2>&1 | grep -i "deprecated"
kubectl convert -f manifest.yaml --output-version apps/v1
```

## Time Management

- **Spend no more than 5 minutes** on any single task before moving on.
- **If stuck**, try `kubectl apply --dry-run=server` to get server-side validation errors.
- **If a pod is not ready**, check: `kubectl describe pod`, `kubectl logs`, `kubectl events`.
- **If a deployment is stuck**, check: `kubectl rollout status`, `kubectl describe deploy`, events.
- **If NetworkPolicy is blocking traffic**, check: DNS (port 53), namespace labels, pod labels, policyTypes.
- **If API version is deprecated**, use `kubectl convert` or manually update the `apiVersion` field.

## Verification Checklist

After every task, verify:
1. `kubectl get <resource> -n <ns>` — resource exists and is in expected state
2. `kubectl describe <resource> -n <ns>` — no errors or warnings
3. `kubectl logs <pod> -n <ns>` (if applicable) — application is running
4. `kubectl get events -n <ns> --sort-by='.lastTimestamp'` — no recent errors
```