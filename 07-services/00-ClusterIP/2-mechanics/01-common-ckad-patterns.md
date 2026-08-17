# Services - ClusterIP - Common CKAD Patterns

## Overview

ClusterIP is the default Kubernetes Service type. It exposes a set of Pods on an internal cluster IP, providing stable network identity and load balancing for internal communication. Understanding the patterns and DNS conventions that ClusterIP relies on is essential for the CKAD exam and for building reliable microservice architectures.

## DNS-Based Service Discovery

Kubernetes provides built-in DNS resolution for Services via CoreDNS. Every Service gets a DNS record that other Pods can use to reach it.

### DNS Naming Convention

```
<service-name>.<namespace>.svc.cluster.local
```

- `<service-name>`: The name of the Service
- `<namespace>`: The namespace where the Service resides
- `.svc.cluster.local`: The default Kubernetes DNS domain

### DNS Resolution Shortcuts

| Form | Example | Resolves To | Scope |
|------|---------|-------------|-------|
| **Short name** | `web-service` | `web-service.<current-namespace>.svc.cluster.local` | Same namespace only |
| **Namespace-qualified** | `web-service.api` | `web-service.api.svc.cluster.local` | Any namespace |
| **Fully qualified** | `web-service.api.svc.cluster.local` | `web-service.api.svc.cluster.local` | Any namespace |
| **Cluster-local** | `web-service.api.svc` | `web-service.api.svc.cluster.local` | Any namespace |

**CKAD Exam Tip:** If a Pod in namespace `default` needs to reach a Service in namespace `api`, it must use the namespace-qualified form `web-service.api` (or the FQDN). Using just `web-service` will attempt DNS resolution in the `default` namespace and fail.

### Example: DNS Resolution in Practice

```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: api
spec:
  selector:
    app: user-api
  ports:
    - name: http
      port: 80
      targetPort: 8080
  type: ClusterIP
---
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: default
spec:
  containers:
    - name: app
      image: my-frontend:latest
      env:
        - name: API_URL
          value: "http://user-service.api.svc.cluster.local"
```

### Verifying DNS Resolution

```bash
# Test DNS from within a Pod
kubectl run dns-test --image=busybox:1.36 --rm -it --restart=Never -- \
  nslookup user-service.api

# Expected output:
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
#
# Name:      user-service.api.svc.cluster.local
# Address 1: 10.96.45.12

# Test with curl from another Pod
kubectl exec -it frontend -- curl -s http://user-service.api.svc.cluster.local/health
```

### Important Namespaces for Services

- `default`: The default namespace where untagged resources go
- `kube-system`: System components (CoreDNS, kube-proxy, etc.)
- `kube-public`: Publicly readable resources
- **Any custom namespace**: Services are namespace-scoped; DNS only works across namespace boundaries when using the FQDN or namespace-qualified form

### Multiple Ports and DNS SRV Records

When a Service exposes multiple ports with named ports, Kubernetes creates SRV (Service) DNS records:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-svc
spec:
  selector:
    app: my-app
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: grpc
      port: 50051
      targetPort: 50051
      protocol: TCP
```

```bash
# SRV record for the 'grpc' port
nslookup -type=SRV _grpc._tcp.multi-port-svc
# Output:
# _grpc._tcp.multi-port-svc.service.ns.svc.cluster.local
#   port 50051, target my-app-pod-xxx.default.pod.cluster.local
```

**CKAD Exam Tip:** Always name your Service ports when a Service exposes multiple ports. Named ports are required for DNS SRV records and are good practice for readability.

```yaml
# ❌ Named port not specified — ambiguous with multiple ports
ports:
  - port: 80
    targetPort: 8080
  - port: 50051
    targetPort: 50051  %comment i think names are mandatory when multiple ports are used

# ✅ Named ports — clear and DNS-friendly
ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: grpc
    port: 50051
    targetPort: 50051
```

## Endpoints and EndpointSlices

A ClusterIP Service with a selector automatically creates EndpointSlices (or the legacy Endpoints object) that list the IP addresses of all matching ready Pods.

### EndpointSlice Example

```bash
kubectl get endpointslices -l kubernetes.io/service-name=user-service -o wide
# NAME              PORTS   ADDRESSES                        READY   AGE
# user-service      80/TCP  10.244.1.5,10.244.2.7,10.244.3.2  True    10m
```

### EndpointSlice vs Legacy Endpoints

```mermaid
flowchart TD
    S[Service Created] --> Sel[Service has selector?]
    Sel -->|Yes| ES[EndpointSlice Controller creates EndpointSlice]
    Sel -->|No| EP[Endpoints object must be created manually]

    ES --> H[Headless Service check]
    EP --> H

    H -->|clusterIP: None| Head[Headless Service]
    H -->|clusterIP set| VIP[ClusterIP Service with Virtual IP]

    Head --> Direct["DNS returns Pod IPs directly<br/>(no ClusterIP proxying)"]
    VIP --> Proxy["DNS returns ClusterIP<br/>kube-proxy load-balances to Pod IPs"]
```

### Common CKAD Patterns with Endpoints

#### Pattern 1: No Selector (Manual Endpoints)

When a Service has no selector, Kubernetes does not create EndpointSlices automatically. You must manually create an Endpoints object:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
spec:
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-db
subsets:
  - addresses:
      - ip: 10.0.1.50  # External database IP
    ports:
      - port: 5432
```

**Use cases:**
- Connecting to an external database outside the cluster
- Routing to a Service in another cluster via mesh
- Pointing a Service to a NodePort or LoadBalancer endpoint

#### Pattern 2: ExternalName Service (CNAME record)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-api
spec:
  type: ExternalName
  externalName: api.example.com
```

This returns a CNAME record pointing to `api.example.com`. No ClusterIP, no Endpoints — just a DNS CNAME.

#### Pattern 3: Headless Service (Direct Pod IPs)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-svc
spec:
  clusterIP: None  # Headless
  selector:
    app: stateful-app
  ports:
    - port: 8080
```

A headless Service does not allocate a ClusterIP. DNS returns the individual Pod IPs directly (one A record per Pod). This is used by StatefulSets for stable network identities.

## Traffic Flow Summary Diagram

```mermaid
flowchart LR
    ClientPod[Client Pod] -->|1. DNS lookup| CoreDNS[CoreDNS]
    CoreDNS -->|2. Returns ClusterIP| ClientPod
    ClientPod -->|3. Sends request to| VS[ClusterIP : port]
    VS -->|4. iptables/IPVS DNAT| kubeProxy[kube-proxy]
    kubeProxy -->|5. Forwards to| Backend1[Pod A IP : targetPort]
    kubeProxy -->|5. Forwards to| Backend2[Pod B IP : targetPort]
    kubeProxy -->|5. Forwards to| Backend3[Pod C IP : targetPort]

    subgraph "kube-proxy on Node"
        VS
        kubeProxy
    end
```

## Best Practices

1. **Always name your Service ports** when there are multiple ports — required for DNS SRV records and CKAD exam clarity.
2. **Use FQDN for cross-namespace calls** (`service.namespace.svc.cluster.local`) — short names only work within the same namespace.
3. **Use `clusterIP: None` intentionally** — headless Services are for StatefulSets or custom service discovery, not for regular load balancing.
4. **Use ExternalName for external services** — avoid creating manual Endpoints when a simple CNAME will do.
5. **Verify Endpoints after creating a Service:**
   ```bash
   kubectl get endpoints <service-name>
   # If empty, the selector does not match any ready Pods
   ```
6. **Use `sessionAffinity: ClientIP`** only when needed (e.g., stateful protocols that require sticky connections). It adds overhead and does not survive Pod restarts.
7. **Do not use ClusterIP Services for external traffic** — use NodePort, LoadBalancer, or Ingress instead. ClusterIP is only reachable from within the cluster.

## Common CKAD Exam Mistakes

| Mistake | Why It Fails | Correct Approach |
|---------|-------------|------------------|
| Using short DNS name for cross-namespace calls | DNS search suffix does not include the other namespace | Use FQDN or `service.other-namespace` |
| Forgetting to name ports in multi-port Service | DNS SRV records not created; confusing `kubectl describe svc` output | Always add `name` to multi-port Services |
| Assuming ClusterIP is reachable externally | ClusterIP is a virtual IP only routable inside the cluster | Use NodePort, LoadBalancer, or Ingress for external access |
| Creating a Service without Endpoints for a non-selector Service | No EndpointSlice created → connection refused | Manually create `Endpoints` object for non-selector Services |
| Using headless Service expecting load balancing | DNS returns all Pod IPs; client must load-balance itself | Use ClusterIP Services for automatic load balancing |

## Troubleshooting

| Symptom | Diagnosis | Fix |
|---------|-----------|-----|
| DNS resolution fails for Service | Service does not exist or is in a different namespace | `kubectl get svc` in the correct namespace; use FQDN |
| DNS resolves but connection refused | Endpoints are empty (selector mismatch, no ready Pods) | `kubectl get endpoints <svc-name>`; check Pod labels vs Service selector |
| DNS resolves to correct ClusterIP but timeout | NetworkPolicy blocking or kube-proxy not functioning | Check NetworkPolicy rules; verify kube-proxy is running |
| `kubectl describe svc` shows empty Endpoints | Service selector does not match any Pods | Verify label selectors match Pod labels |
| Connection works from same node but not remote nodes | CNI or network policy issue | Check CNI plugin status; audit NetworkPolicy |
