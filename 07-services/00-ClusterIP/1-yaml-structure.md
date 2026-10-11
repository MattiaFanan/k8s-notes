# Services - ClusterIP - YAML Structure

A **ClusterIP** service is the default Kubernetes service type. It exposes the application on an internal cluster IP address, making it accessible only from within the cluster. This is the standard way to enable communication between services or components running inside the cluster.

## Service Manifest (ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  sessionAffinity: None
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `spec.type` | No | Defaults to `ClusterIP`. Possible values: `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName`. |
| `spec.selector` | Yes | Must match Pod `labels` exactly. The selector is a subset of Pod labels — Pods can have additional labels not in the selector. |
| `spec.ports[].port` | Yes | Service port exposed inside cluster. |
| `spec.ports[].targetPort` | Yes | Container port on the Pod. |
| `spec.ports[].name` | Recommended | Required if multiple ports; used by DNS and probes. |
| `spec.sessionAffinity` | No | `None` (default) or `ClientIP`. Enables sticky sessions based on client IP. |
| `spec.sessionAffinityConfig.clientIP.timeoutSeconds` | No | Timeout for ClientIP affinity (default 10800s / 3h). Max 86400s (24h). |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `spec.type` | Optional | Yes | Defaults to `ClusterIP`. Possible values: `ClusterIP`, `NodePort`, `LoadBalancer`, `ExternalName`. Explicitly declaring it is a best practice for clarity. |
| `spec.selector` | Required | Yes | Matches Pod `labels` to determine endpoints. The selector is a subset of Pod labels — Pods can have additional labels not in the selector. Mutable; use `kubectl set selector` or `kubectl patch` to change. |
| `spec.ports[].port` | Required | Yes | Editable via `kubectl edit`; changes take effect immediately. |
| `spec.ports[].targetPort` | Required | Yes | Editable via `kubectl edit`; referenced Pod containerPort must exist. |
| `spec.ports[].name` | Important | Yes | Required when multiple ports are exposed. Used by DNS SRV records and health probes. |
| `spec.sessionAffinity` | Optional | Yes | `None` (default) or `ClientIP`. Enables sticky sessions. Only affects how kube-proxy routes connections; does not survive Pod restarts. |
| `spec.sessionAffinityConfig.clientIP.timeoutSeconds` | Optional | Yes | ClientIP affinity timeout in seconds (default 10800). Range: 1-86400. |
| `spec.clusterIP` | N/A | No | Immutable after creation. This is a virtual IP automatically assigned unless explicitly set to `None` (headless) or a specific IP at creation time. |
