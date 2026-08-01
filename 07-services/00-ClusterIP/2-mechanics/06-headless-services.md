# Headless Services (ClusterIP: None)

A headless service is a Service with `clusterIP: None`. It does not allocate a ClusterIP and does not proxy traffic. Instead, it returns the Pod IPs directly via DNS, allowing clients to connect to individual pods.

## How Headless Services Work

### DNS Behavior

For a normal ClusterIP service, DNS returns the ClusterIP:
```
my-svc.my-namespace.svc.cluster.local -> 10.0.0.1
```

For a headless service, DNS returns the Pod IPs directly:
```
my-svc.my-namespace.svc.cluster.local -> 10.244.1.5, 10.244.2.3
```

### SRV Records for Named Ports

Headless services also support SRV DNS records for named ports:
```
_port._tcp.my-svc.my-namespace.svc.cluster.local -> <pod-ip>:<port>
```

## YAML Structure

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-svc
spec:
  clusterIP: None
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: 8080
```

## Use Cases

### StatefulSets

Headless services are essential for StatefulSets. They provide stable network identities for pods:

```
pod-0.headless-svc.default.svc.cluster.local
pod-1.headless-svc.default.svc.cluster.local
```

### Direct Pod-to-Pod Communication

When you need to connect to specific pods rather than load-balanced endpoints.

### Service Discovery with Custom Logic

When the client needs to discover all pod IPs and implement its own load balancing or routing.

### Database Clusters

For databases that require direct pod-to-pod communication (e.g., etcd, Kafka, Cassandra).

## Comparison: Normal vs Headless Service

| Feature | Normal Service | Headless Service |
|---------|---------------|-----------------|
| ClusterIP | Allocated | None |
| DNS returns | ClusterIP | Pod IPs |
| Load balancing | kube-proxy (iptables/IPVS) | Client-side |
| Pod discovery | Via Endpoints/EndpointSlices | Via DNS A records |
| Use with StatefulSets | Optional | Required |

## Verification

```bash
# Check if a service is headless
kubectl get svc headless-svc -o jsonpath='{.spec.clusterIP}'
# Expected: None

# DNS lookup for headless service
kubectl exec -it debug-pod -- nslookup headless-svc.default.svc.cluster.local
# Expected: Returns Pod IPs directly

# DNS lookup for StatefulSet pod
kubectl exec -it debug-pod -- nslookup pod-0.stateful-svc.default.svc.cluster.local
# Expected: Returns specific Pod IP

# Check endpoints
kubectl get endpoints headless-svc
kubectl get endpointslices -l kubernetes.io/service-name=headless-svc
```

## Exam Relevance

- Headless services are in CKAD scope under SN-02 (Provide and troubleshoot access to applications via services).
- Understand when to use `clusterIP: None` vs a normal ClusterIP.
- Know the DNS behavior difference between normal and headless services.
- Headless services are required for StatefulSet stable network identities.

## Common Pitfalls

1. **Using headless service when load balancing is needed**: Headless services do not load balance. Use a normal ClusterIP service for load-balanced access.
2. **Forgetting that DNS returns pod IPs directly**: Clients must handle multiple IPs and potential pod churn.
3. **Not using headless services with StatefulSets**: StatefulSets require a headless service for stable network identities.

## Commands

```bash
# Create a headless service
kubectl create service clusterip headless-svc --tcp=80:8080 --clusterip=None

# Or via YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: headless-svc
spec:
  clusterIP: None
  selector:
    app: my-app
  ports:
  - name: http
    port: 80
    targetPort: 8080
EOF

# Verify clusterIP is None
kubectl get svc headless-svc -o jsonpath='{.spec.clusterIP}'

# DNS lookup
kubectl exec -it debug-pod -- nslookup headless-svc.default.svc.cluster.local
```

## See also

- [ClusterIP CKAD Tips](00-ClusterIP/5-ckad-tips.md)
- [Services Overview](../../0-overview.md)
- [StatefulSets](../../10-crds-operators/2-mechanics/03-operators.md)