# Services - LoadBalancer - Common CKAD Patterns

This file covers the most frequently tested LoadBalancer patterns on the CKAD and CKA exams. Understanding LoadBalancer means understanding how it builds on NodePort and how cloud integration works.

## Why LoadBalancer Matters for CKAD

The LoadBalancer Service type is the standard way to expose workloads externally in cloud environments. On the exam, you will encounter scenarios involving:

- Creating a LoadBalancer Service and waiting for its external IP
- Understanding why a LoadBalancer stays in `Pending` state
- Configuring annotations for cloud-specific behavior
- Choosing between NodePort, LoadBalancer, and Ingress
- Debugging LoadBalancer connectivity issues

## Core CKAD Patterns

### Pattern 1: Create a LoadBalancer Service

The most basic task is to expose a deployment as a LoadBalancer Service.

```bash
# Create a deployment
kubectl create deployment web --image=nginx:1.25 --replicas=3

# Expose it as a LoadBalancer Service
kubectl expose deployment web --type=LoadBalancer --port=80 --target-port=8080

# Check the Service status
kubectl get svc web
```

In a cloud environment, the output will eventually show an external IP:

```
NAME   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
web    LoadBalancer   10.96.0.10      203.0.113.50    80:31234/TCP   45s
```

In a bare-metal or local environment (e.g., Minikube, kind), the `EXTERNAL-IP` will remain `<pending>` until a provisioner like MetalLB is installed.

### Pattern 2: Wait for External IP Provisioning

LoadBalancers in cloud environments take time to provision. The exam may test your patience or your ability to check the status programmatically.

```bash
# Watch the Service until EXTERNAL-IP is assigned
kubectl get svc web -w

# Check the Service status in JSON format
kubectl get svc web -o jsonpath='{.status.loadBalancer.ingress}'

# Describe the Service for events (shows provisioning progress)
kubectl describe svc web
```

The events section of `kubectl describe svc` will show messages like:

```
Events:
  Type    Reason                Age   From                Message
  ----    ------                ----  ----                -------
  Normal  EnsuringLoadBalancer  5s    service-controller  Ensuring load balancer
  Normal  EnsuredLoadBalancer   30s   service-controller  Ensured load balancer
```

### Pattern 3: LoadBalancer with Specific Annotations

Cloud providers use annotations to configure load balancer behavior. The exact annotations vary by provider.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
  annotations:
    # AWS ELB specific
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/aws-load-balancer-internal: "true"
    service.beta.kubernetes.io/aws-load-balancer-scheme: internal
    # GCP specific
    cloud.google.com/load-balancer-type: "internal"
    # Azure specific
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

```bash
# Apply and check
kubectl apply -f web-lb.yaml
kubectl get svc web-lb
```

### Pattern 4: Debug a LoadBalancer Stuck in Pending

When a LoadBalancer Service remains in `Pending` state, follow this debugging path:

```bash
# 1. Check the Service events
kubectl describe svc web-lb | grep -A 20 Events

# 2. Check if the cloud controller manager is running
kubectl get pods -n kube-system | grep cloud-controller

# 3. Check if the cloud provider is configured on the API server
# Look for --cloud-provider and --cloud-config flags on kube-apiserver
ps aux | grep kube-apiserver | grep cloud

# 4. Check if the cloud node is registered
kubectl get nodes -o wide

# 5. In bare-metal environments, check if MetalLB is installed
kubectl get pods -n metallb-system
kubectl get l2advertisements

# 6. Check if the cloud provider has reached its quota
# (This requires checking the cloud provider's console)
```

### Pattern 5: LoadBalancer with ExternalTrafficPolicy

Just like NodePort, LoadBalancer Services support `externalTrafficPolicy`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

- `Cluster` (default): Traffic is distributed across all nodes, source IP is lost.
- `Local`: Traffic is only forwarded to nodes running backend Pods, source IP is preserved.

```bash
# Verify the policy
kubectl get svc web-lb -o jsonpath='{.spec.externalTrafficPolicy}'
```

### Pattern 6: LoadBalancer with Session Affinity

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-lb
spec:
  type: LoadBalancer
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```

```bash
# Verify session affinity
kubectl get svc web-lb -o jsonpath='{.spec.sessionAffinity}'
```

## CKAD Exam Tips

| Scenario | Recommended Approach |
|---|---|
| Expose an HTTP app with host/path routing | Ingress (not LoadBalancer) |
| Quick external access in cloud | LoadBalancer |
| Quick external access in bare-metal | NodePort + MetalLB |
| Need a static external IP | LoadBalancer with static IP annotation |
| Need source IP preservation | LoadBalancer with `externalTrafficPolicy: Local` |
| Database or non-HTTP service | LoadBalancer or NodePort |

## Best Practices

- **Always check events** when a LoadBalancer is stuck in `Pending`. The events contain the root cause.
- **Use annotations sparingly** and only when you need cloud-specific behavior. Over-annotating makes Services harder to manage.
- **Prefer Ingress over LoadBalancer** for HTTP/HTTPS applications. Ingress is cheaper, more flexible, and provides Layer 7 features.
- **Set `externalTrafficPolicy: Local`** when source IP preservation matters (e.g., for rate limiting, logging, or compliance).
- **Use `sessionAffinity: ClientIP`** for stateful applications that require sticky sessions, but be aware that it reduces load balancing efficiency.
- **Clean up unused LoadBalancer Services** — each one provisions a real cloud load balancer that incurs costs.

## Common Pitfalls

- **Assuming LoadBalancer always works.** In bare-metal or local environments (Minikube, kind, k3s), LoadBalancer stays `Pending` unless a provisioner like MetalLB is installed.
- **Not checking cloud provider quotas.** Cloud providers have limits on the number of load balancers per region. Exceeding these quotas causes LoadBalancer provisioning to fail silently.
- **Confusing LoadBalancer with Ingress.** LoadBalancer operates at Layer 4 (TCP/UDP). Ingress operates at Layer 7 (HTTP/HTTPS) and provides routing, TLS termination, and rewrites.
- **Forgetting that LoadBalancer uses NodePort internally.** The cloud load balancer forwards traffic to the nodePort on each node. If nodePort traffic is blocked by a firewall, the LoadBalancer will not work.
- **Ignoring the cost implications.** Each LoadBalancer Service provisions a real cloud load balancer. In AWS, this costs approximately $16-25/month per ALB/NLB plus data processing fees.