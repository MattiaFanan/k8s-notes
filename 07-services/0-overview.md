# Services - Overview & How Types Interconnect

## The Problem: Pods Are Ephemeral

Pods come and go. A Deployment may replace a Pod due to a rollout, scaling, or a node failure. Every new Pod gets a **new IP** from the CNI plugin. Your application cannot rely on hardcoded Pod IPs.

Services solve this by providing **stable network endpoints** that abstract over a dynamic set of Pods.

## The ClusterIP Foundation

At its core, every Service is a **ClusterIP**:
- A stable virtual IP allocated from a configured range.
- Kube-controller-manager watches the Service selector and automatically creates `Endpoints` or `EndpointSlice` objects pointing to ready Pod IPs.
- CoreDNS registers a DNS A record: `<svc-name>.<namespace>.svc.cluster.local` -> ClusterIP.
- kube-proxy programs iptables/IPVS rules on **every node** so traffic to the ClusterIP is forwarded to actual Pod ports.

**Every other Service type stacks on top of ClusterIP behavior.**

## How Types Relate

```text
ClusterIP    = stable internal IP + DNS + endpoint tracking
      |
NodePort     = ClusterIP + exposes same port on every node's physical IP (30000-32767)
      |
LoadBalancer = NodePort + cloud provider provisions external load balancer pointing to node IPs
      |
ExternalName = no ClusterIP at all; instead returns CNAME to external DNS name
      |
Ingress      = Layer 7 HTTP/HTTPS router; needs an Ingress Controller Pod + ClusterIP Service backends
```

## Key Mental Model

- **ClusterIP**: "I want to reach this app from inside the cluster."
- **NodePort**: "I also want to reach it directly from node IPs."
- **LoadBalancer**: "I want the cloud to give me a public IP for this."
- **ExternalName**: "I want to alias this name to some external host."
- **Ingress**: "I want host/path-based routing to multiple backend apps."

## Ports Mental Model

| Concept | What it is |
| :--- | :--- |
| Service `port` | Port on the ClusterIP (internal clients use this). |
| `targetPort` | Port on the actual Pod container. |
| `nodePort` | Port exposed on every node's physical IP (only NodePort/LoadBalancer). |
| Service selector | Filters which Pods are added to Endpoints. |

Traffic always flows: **Client -> Service VIP:port -> kube-proxy -> Pod IP:targetPort**.

## Ingress Special Case

Ingress is not a `Service` type. It is a set of rules that routes HTTP traffic to **existing Services**. An Ingress Controller (usually a Deployment + Service) watches Ingress resources and configures itself accordingly.

## Exam Takeaway

- Start with `ClusterIP` for internal-only access.
- Add `NodePort` for direct node-level exposure.
- Use `LoadBalancer` in cloud environments for external IP.
- Use `ExternalName` to map to external databases without migrating them.
- Use `Ingress` when you need host/path-based routing across many apps.
