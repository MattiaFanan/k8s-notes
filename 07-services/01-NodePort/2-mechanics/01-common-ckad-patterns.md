# Services - NodePort - Common CKAD Patterns

This file covers the most frequently tested NodePort patterns on the CKAD and CKA exams. Mastering these patterns ensures you can quickly expose workloads and debug connectivity issues under exam conditions.

## Why NodePort Matters for CKAD

NodePort is the simplest way to expose a Service externally. It is the foundation that other Service types (LoadBalancer, Ingress) build upon. On the exam, you will often need to:

- Expose a deployment on a specific port
- Verify that a Service is correctly routing to Pods
- Debug connectivity issues between nodes and Pods
- Choose the right Service type for a given scenario

## Core CKAD Patterns

### Pattern 1: Expose a Deployment with NodePort

The most common task is to take an existing Deployment and expose it via NodePort.

```bash
# Create a deployment first
kubectl create deployment web --image=nginx:1.25 --replicas=3

# Expose it as a NodePort Service on port 80, targeting container port 8080
kubectl expose deployment web --type=NodePort --port=80 --target-port=8080

# Verify the Service and find the assigned nodePort
kubectl get svc web
```

The output will show something like:

```
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web    NodePort   10.96.0.10      <none>        80:31234/TCP   10s
```

The number `31234` is the auto-assigned nodePort in the default range 30000-32767.

### Pattern 2: Specify a Fixed nodePort

When the exam requires a specific port (e.g., "use port 30080"), you must explicitly set `nodePort` in the Service spec. The port must fall within the `--service-node-port-range` (default 30000-32767).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30080
```

Apply with:

```bash
kubectl apply -f web-nodeport.yaml
```

If you specify a `nodePort` outside the allowed range, the API server will reject it with a `Forbidden` error.

### Pattern 3: Verify NodePort Connectivity

After creating a NodePort Service, always verify that traffic can reach the backend Pods:

```bash
# Get the node IP
kubectl get nodes -o wide

# Get the assigned nodePort
kubectl get svc web-nodeport

# Test from another Pod on the cluster
kubectl run -it --rm debug --image=busybox:1.36 -- sh
# Inside the debug pod:
wget -qO- http://<NodeIP>:30080

# Or test from the node itself (if you have SSH access)
curl http://<NodeIP>:30080
```

### Pattern 4: Debug a NodePort That Is Not Working

When a NodePort Service does not respond, follow this systematic debugging path:

```bash
# 1. Check the Service exists and has endpoints
kubectl get svc web-nodeport -o wide
kubectl get endpoints web-nodeport

# 2. Check that Pods are running and ready
kubectl get pods -l app=web

# 3. Check kube-proxy is running on each node
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# 4. Check iptables/IPVS rules on the node
# On the node where traffic should enter:
sudo iptables -t nat -L KUBE-SERVICES | grep 30080
sudo ipvsadm -Ln | grep 30080

# 5. Check if the nodePort is listening
sudo ss -tlnp | grep 30080
```

### Pattern 5: NodePort with `externalTrafficPolicy`

Understanding the difference between `Cluster` and `Local` is a frequent exam topic.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport-local
spec:
  type: NodePort
  externalTrafficPolicy: Local
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30080
```

- `Cluster` (default): Traffic arriving at any node is forwarded to any backend Pod, even on other nodes. Source IP is lost.
- `Local`: Traffic is only forwarded to Pods on the same node. Source IP is preserved. If a node has no Pods, traffic to that node's nodePort is dropped (for NodePort Services, there is no cloud load balancer health check to redirect traffic; `healthCheckNodePort` only applies when `type` is `LoadBalancer`).

```bash
# Verify the traffic policy
kubectl get svc web-nodeport-local -o yaml | grep externalTrafficPolicy
```

## CKAD Exam Tips

| Scenario | Recommended Approach |
|---|---|
| Quick temporary access to a pod | `kubectl port-forward` or NodePort |
| Expose a deployment externally on bare-metal | NodePort |
| Need a stable external IP | LoadBalancer (or MetalLB for bare-metal) |
| HTTP routing with host/path rules | Ingress (not NodePort) |
| Need source IP preservation | NodePort with `externalTrafficPolicy: Local` |

## Best Practices

- **Avoid hardcoding nodePort values** unless the exam or environment requires it. Auto-assigned ports reduce the risk of conflicts.
- **Use `externalTrafficPolicy: Local`** when preserving client source IPs is important (e.g., for rate limiting or logging).
- **Always verify endpoints** with `kubectl get endpoints <svc-name>` before debugging connectivity. If endpoints are empty, the selector does not match any Pods.
- **Use `--dry-run=client -o yaml`** to generate YAML templates quickly during the exam:
  ```bash
  kubectl create svc nodeport web --tcp=80:8080 --dry-run=client -o yaml > web-svc.yaml
  ```

## Common Pitfalls

- **Forgetting that nodePort must be in range 30000-32767.** If you specify `nodePort: 80`, the API server rejects it.
- **Assuming NodePort gives external DNS resolution.** NodePort only opens a port on each node's IP. You need the node's IP address, not a hostname.
- **Not checking kube-proxy health.** If kube-proxy is not running on a node, NodePort traffic to that node will fail silently.
- **Confusing `port` and `targetPort`.** `port` is the port on the Service (and the nodePort port if using NodePort). `targetPort` is the port on the Pod. They can be the same number but serve different purposes.
- **Ignoring `externalTrafficPolicy` when source IP matters.** The default `Cluster` policy rewrites the source IP to a node-internal IP, which breaks client-based routing logic.