# ConfigMaps & Secrets - Combination Patterns

## Overview

In Kubernetes, ConfigMaps and Secrets are often used together in the same Pod to provide configuration and credentials separately. Understanding how to combine them — and the different consumption patterns available — is essential for building secure and maintainable workloads.

## Why Separate ConfigMap and Secret?

- **Security**: Secrets are stored differently in etcd and can be encrypted at rest. ConfigMaps store plaintext data and are not intended for sensitive information.
- **Lifecycle separation**: Configuration can change frequently (hot-reload via volume mounts) while credentials change rarely.
- **Access control**: RBAC can be scoped to allow reading ConfigMaps broadly but Secrets narrowly, following the principle of least privilege.
- **Auditability**: Most audit tools treat Secret access differently from ConfigMap access, making it easier to detect credential misuse.

## Common Combination Patterns

### Pattern 1: ConfigMap as Volume + Secret as Environment Variable

Mount shared configuration as files while injecting credentials as environment variables.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production
  APP_LOG_LEVEL: info
  APP_MAX_WORKERS: "4"
---
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  DB_USER: YWRtaW4=
  DB_PASSWORD: UEBzc3cwcmQh
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
    - name: app
      image: myapp:latest
      env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_PASSWORD
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: DB_USER
      volumeMounts:
        - name: config-volume
          mountPath: /etc/app/config
          readOnly: true
  volumes:
    - name: config-volume
      configMap:
        name: app-config
```

**When to use:** When the application expects credentials in environment variables but configuration in files. Many frameworks (e.g., Spring Boot, Django) prefer file-based configuration while database drivers often use env vars for credentials.

### Pattern 2: Both as Volume Mounts

Mount both ConfigMap and Secret as separate directories in the same Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-2
spec:
  containers:
    - name: app
      image: myapp:latest
      volumeMounts:
        - name: config-volume
          mountPath: /etc/app/config
          readOnly: true
        - name: secret-volume
          mountPath: /etc/app/secrets
          readOnly: true
  volumes:
    - name: config-volume
      configMap:
        name: app-config
    - name: secret-volume
      secret:
        secretName: db-credentials
```

**When to use:** When the application reads both config and credentials from files and you want them organized in separate directories.

### Pattern 3: envFrom for Bulk Secret/ConfigMap Injection

Use `envFrom` to inject all keys from a ConfigMap or Secret as environment variables at once.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-3
spec:
  containers:
    - name: app
      image: myapp:latest
      envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: db-credentials
```

**⚠ Pitfall:** `envFrom` injects all keys from the referenced object. If the ConfigMap contains a key that clashes with an existing environment variable (or one set via `env`), the `envFrom` value wins for keys not already defined by `env`. This can cause silent configuration overrides.

**Best Practice:** Be explicit with `env` for critical settings and use `envFrom` for bulk, non-conflicting configuration only.

### Pattern 4: ConfigMap/Secret as both CLI Args and Volume Mounts

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-4
spec:
  containers:
    - name: app
      image: myapp:latest
      command: ["/bin/sh", "-c"]
      args:
        - ./start.sh --env $(APP_ENV) --workers $(APP_MAX_WORKERS)
      env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_ENV
        - name: APP_MAX_WORKERS
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_MAX_WORKERS
      volumeMounts:
        - name: secret-volume
          mountPath: /etc/app/secrets
          readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: db-credentials
```

**Note:** The `$(VAR)` syntax in `args` and `command` uses the container's environment variables. These are substituted by the container runtime before the command executes. Environment variables set via `valueFrom` in the same `env` block are available for substitution.

### Pattern 5: Subpath Mounts for Selective File Access

When you only need a single key from a ConfigMap or Secret, use `subPath` to mount just that file rather than the entire volume.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-5
spec:
  containers:
    - name: app
      image: myapp:latest
      volumeMounts:
        - name: single-secret
          mountPath: /etc/app/db-password
          subPath: DB_PASSWORD
          readOnly: true
  volumes:
    - name: single-secret
      secret:
        secretName: db-credentials
```

**Advantage:** The Secret volume exposes all keys as files, but `subPath` mounts only one file at the specified path. This reduces the attack surface — the container only sees the specific secret it needs.

**⚠ Pitfall:** `subPath` mounts do not receive updates when the underlying Secret or ConfigMap changes. The file at the subpath will reflect the original data until the Pod restarts. If you need hot-reload of secret values, avoid `subPath` and mount the full volume.

## Consumption Method Comparison

```mermaid
flowchart TD
    Pod[Pod Consumes Config/Secret] --> Method{Method}

    Method --> Env["Environment Variables<br/>(env / envFrom)"]
    Method --> Args["Command Args<br/>$(VAR) substitution]
    Method --> Mount["Volume Mount<br/>(files on filesystem]

    Env --> HotReload{"Hot Reload?"}
    Args --> HotReload
    Mount --> HotReload

    HotReload -->|No| EnvIssue["⚠ Requires Pod restart<br/>to pick up changes"]
    HotReload -->|Eventually| MountInfo["✅ Volume files update<br/>within ~1 minute<br/>(Kubelet sync period]"]

    EnvIssue --> BestPractice["Use ConfigMap/Secret for<br/>initial bootstrap values only"]
    MountInfo --> BestPractice2["Best for dynamic<br/>configuration changes"]
```

## Security Considerations for Combination Patterns

1. **Never base64-encoded and commit Secrets to version control** — the encoded values are trivially decoded (`echo UEBzc3cwcmQh | base64 -d`). Use Sealed Secrets, External Secrets Operator, or vault injection instead.
2. **Use `readOnly: true` on all volume mounts** for both ConfigMaps and Secrets to prevent accidental modification.
3. **Avoid `envFrom` when you have secrets with many keys** — it exposes all of them as environment variables, which can be leaked via `/proc/<pid>/environ` or crash logs.
4. **Prefer volume mounts over environment variables for secrets** — environment variables can be inspectable via process listing, while file-based mounts are harder to leak.
5. **Set `defaultMode` on Secret volumes** to restrict file permissions:
   ```yaml
   volumes:
     - name: secret-volume
       secret:
         secretName: db-credentials
         defaultMode: 0440   # Read-only for owner and group
   ```

## Best Practices

1. **Keep ConfigMaps for non-sensitive config and Secrets for sensitive data.** Do not mix the two into a single ConfigMap.
2. **Use `secretKeyRef` and `configMapKeyRef` for single-key injection** — it is explicit and auditable.
3. **Use `envFrom` for bulk non-sensitive config injection** only when keys are unlikely to clash.
4. **Use subPath mounts** to limit the surface area of Secrets exposed to a container.
5. **Name secrets and configmaps with application-scoped names** (e.g., `app-name-db-config`, `app-name-api-key`) to avoid naming collisions across namespaces.
6. **Always set `readOnly: true` in volumeMounts** when mounting ConfigMaps or Secrets.

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Pod fails to create with `Secret not found` | Secret name typo or wrong namespace | `kubectl get secret` in the correct namespace |
| `command` args not substituting `$(VAR)` | Variable not defined in `env` block before the command | Define all referenced env vars in the `env` section |
| `subPath` mount not updating after Secret change | subPath mounts are immutable post-mount | Do not use subPath for values that need hot-reload |
| App reads wrong secret value | `envFrom` overwrites an `env` variable | Use explicit `env` for critical variables; avoid `envFrom` for Secrets |
| Permission denied on mounted secret file | Default file mode is 0644 or 0600 | Set `defaultMode: 0440` or `0400` on the volume |
| ConfigMap changes not reflected in running Pod | Volume-mounted files update slowly; env vars do not update at all | Use volume mounts for hot-reload; restart Pod for env var changes |