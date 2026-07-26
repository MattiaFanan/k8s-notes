# ConfigMaps & Secrets - YAML Structure

ConfigMaps store non-sensitive configuration data as key-value pairs or files, decoupling configuration from container images so the same image can run in different environments. Secrets serve the same purpose but hold sensitive data such as passwords, tokens, and keys, and optionally encode the values in base64. Both resources are consumed by pods as environment variables, command-line arguments, or mounted files, keeping application code independent of deployment-specific settings.

## ConfigMap Manifest

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: "production"
  DB_HOST: "postgres.default.svc.cluster.local"
  config.properties: |
    timeout=30
    retries=5
```

## Using ConfigMap as Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    env:
    - name: APP_MODE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_MODE
    envFrom:
    - configMapRef:
        name: app-config
```

## Secret Manifest

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
stringData:
  username: admin
  password: s3cret
```

## Using Secret as Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx:1.25
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `data` | Required | Yes | Key-value map for ConfigMaps; keys must be strings. For Secrets, values must be base64-encoded or use `stringData` for plain-text convenience. |
| `metadata.name` | Required | Yes | Name of the resource within the namespace. Must be a valid DNS subdomain name. |
| `type` | Optional (defaults to `Opaque` for Secrets) | Yes | Only applies to Secrets. Other types: `kubernetes.io/service-account-token`, `kubernetes.io/dockerconfigjson`, `kubernetes.io/basic-auth`. |
| `stringData` | Optional | Yes | Accepts plain-text values for Secrets; automatically base64-encodes them at creation. Mutually exclusive with `data` for the same key. |
| `immutable` | Optional | Yes | Set to `true` to prevent changes to the data field after creation. Useful for audit-critical ConfigMaps/Secrets. |

### General Notes

- **Key ordering**: The order of keys in `data` (ConfigMap/Secret) is not guaranteed; do not rely on alphabetical or insertion order.
- **`kubectl edit` behavior**: Editing an existing ConfigMap or Secret with `kubectl edit` performs a patch-like update — existing keys are preserved unless explicitly removed, and new keys are added.
- **Integer/byte values**: Values in `data` must be strings. Integer or byte values must be converted to their string representation.

### Secret Types

| Type | Description |
|---|---|
| `Opaque` | Generic base64-encoded secret data (default). |
| `kubernetes.io/service-account-token` | Service account token with `token`, `ca.crt`, and `namespace` fields. |
| `kubernetes.io/dockerconfigjson` | Docker registry credentials stored as a JSON `dockerconfigjson` string. |
| `kubernetes.io/basic-auth` | Basic authentication credentials with `username` and `password` fields. |
