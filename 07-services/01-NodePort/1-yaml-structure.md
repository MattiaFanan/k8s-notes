# Services - NodePort - YAML Structure

A **NodePort** service exposes the application on a static port on each cluster node's IP address. External clients can reach the service by connecting to any node's IP on that port. This is useful for basic external access without requiring a cloud load balancer.

## Service Manifest (NodePort)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
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

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `spec.type` | No | Set to `NodePort` for external node-level access. |
| `spec.ports[].nodePort` | Conditional | Omit for auto-allocation (30000-32767). |
| `spec.ports[].port` | Yes | Cluster-internal port. |
| `spec.ports[].targetPort` | Yes | Container port on Pod. |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `spec.type` | Required | Yes | Must be `NodePort` to expose application on each cluster node's static port. |
| `spec.ports[].nodePort` | Conditional | Yes | Range 30000-32767; omit for auto-allocation. |
| `spec.ports[].port` | Required | Yes | Cluster-internal port. |
| `spec.ports[].targetPort` | Required | Yes | Container port on Pod; relationship same as ClusterIP. |
| `spec.ports[].protocol` | Optional | Yes | Typically `TCP` or `UDP`. |
| `spec.selector` | Important | No | Immutable; determines which Pods receive traffic. |
| `spec.externalTrafficPolicy` | Optional | Yes | `Cluster` (default) preserves source IP; use `Local` to keep client source IP on the node. |
| `spec.clusterIP` | Optional | Yes | Typically left empty to allocate a cluster-internal IP; not needed for external-only NodePort access. |
| `spec.healthCheckNodePort` | Optional | Yes | Custom health check port for nodes when `externalTrafficPolicy` is `Local`; auto-assigned if omitted. |
