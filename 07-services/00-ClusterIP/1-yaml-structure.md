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
```

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `spec.type` | No | Defaults to `ClusterIP`. Internal cluster access only. |
| `spec.selector` | Yes | Must match Pod `labels` exactly. |
| `spec.ports[].port` | Yes | Service port exposed inside cluster. |
| `spec.ports[].targetPort` | Yes | Container port on the Pod. |
| `spec.ports[].name` | Recommended | Required if multiple ports; used by DNS and probes. |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `spec.type` | Optional | Yes | Defaults to `ClusterIP`. Explicitly declaring it is a best practice for clarity. |
| `spec.selector` | Required | No | Immutable after creation. Endpoint discovery is automatic via selector matching Pod labels; changing the selector requires `kubectl patch` or replace. |
| `spec.ports[].port` | Required | Yes | Editable via `kubectl edit`; changes take effect immediately. |
| `spec.ports[].targetPort` | Required | Yes | Editable via `kubectl edit`; referenced Pod containerPort must exist. |
| `spec.ports[].name` | Important | Yes | Required when multiple ports are exposed. Used by DNS SRV records and health probes. |
| `clusterIP` | N/A | No | Immutable after creation. Assigned automatically unless explicitly set at creation time. |
