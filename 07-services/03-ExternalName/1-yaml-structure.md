# Services - ExternalName - YAML Structure

An **ExternalName** service maps a service name to an external DNS name (a CNAME record) rather than selecting Pods with a selector. It is used to redirect traffic to services that exist outside the cluster, such as a database or API hosted on an external endpoint. No proxy or endpoint object is needed.

## Service Manifest (ExternalName)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-db-service
spec:
  type: ExternalName
  externalName: mydb.example.com
```

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `spec.type` | Yes | Must be `ExternalName`. |
| `spec.externalName` | Yes | DNS CNAME target (external service). |

## Field Reference

| Field | Required | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :---: | :---: | :--- |
| `spec.type` | Yes | Yes | Must be `ExternalName`. |
| `spec.externalName` | Yes | Yes | DNS CNAME target. Editable, but changes propagate via DNS and may be cached by clients. |
| `spec.selector` | No | — | Not allowed for ExternalName services. |
| `spec.ports` / `spec.targetPort` | No | — | Not allowed for ExternalName services. |
| `spec.clusterIP` | No | — | Ignored if specified. |
