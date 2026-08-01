# Security Contexts, Probes & Pod Security Standards — YAML Structure

Security contexts control the privilege and identity settings of pods and containers, while probes (liveness, readiness, and startup) monitor the health of running containers. Pod Security Standards (PSS) define baseline policies for pod security enforced via namespace labels.

## SecurityContext at Pod Level

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.25
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

## Liveness & Readiness Probes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /ready
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
```

## Startup Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: slow-start
spec:
  containers:
  - name: app
    image: legacy-app:1.0
    startupProbe:
      tcpSocket:
        port: 8080
      failureThreshold: 30
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
```

## Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
     limits.memory: 16Gi

## Privileged Policy

No restrictions. Equivalent to running without any security policies.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
  labels:
    pod-security.kubernetes.io/enforce: privileged
spec:
  containers:
  - name: app
    image: nginx:1.25
    securityContext:
      privileged: true
      allowPrivilegeEscalation: true
      capabilities:
        add: ["ALL"]
```

## Baseline Policy

Minimal restrictions that prevent known privilege escalations.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: baseline-pod
  labels:
    pod-security.kubernetes.io/enforce: baseline
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 2000
  containers:
  - name: app
    image: nginx:1.25
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

## Restricted Policy

Strongest restrictions. Enforces the most secure defaults.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
  labels:
    pod-security.kubernetes.io/enforce: restricted
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:1.25
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

## Pod Security Admission Labels

| Label | Effect |
|-------|--------|
| `pod-security.kubernetes.io/enforce: privileged` | Enforce privileged policy |
| `pod-security.kubernetes.io/enforce: baseline` | Enforce baseline policy |
| `pod-security.kubernetes.io/enforce: restricted` | Enforce restricted policy |
| `pod-security.kubernetes.io/warn: baseline` | Warn if not baseline |
| `pod-security.kubernetes.io/audit: restricted` | Audit if not restricted |

## Namespace-Level PSS Enforcement

```bash
# Label a namespace to enforce restricted PSS
kubectl label namespace myns pod-security.kubernetes.io/enforce=restricted

# Label a namespace to warn about baseline
kubectl label namespace myns pod-security.kubernetes.io/warn=baseline

# Label a namespace to audit restricted
kubectl label namespace myns pod-security.kubernetes.io/audit=restricted
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `spec.securityContext` (pod-level) | Optional / Important | Yes | Sets identity and privilege policies inherited by all containers. Prefer pod-level for consistency. |
| `spec.containers[].securityContext` (container-level) | Optional / Important | Yes | Overrides pod-level securityContext per container. Use for per-app needs. |
| `runAsUser` | Optional / Important | Yes | UID for container processes. Set to non-root (e.g., `1000`) to prevent root ownership. |
| `runAsGroup` | Optional / Important | Yes | Primary GID for container processes. |
| `fsGroup` | Optional / Important | Yes | GID for volume ownership in the pod. Ensures volumes are writable by non-root. |
| `allowPrivilegeEscalation` | Optional / Important | Yes | Defaults to `true`. Set to `false` to block `setuid` binaries and privilege escalation. |
| `readOnlyRootFilesystem` | Optional / Important | Yes | Prevents writes to the container rootfs. Mount writable volumes for logs/outputs. |
| `capabilities` | Optional / Important | Yes | Use `drop: [ALL]`; add back only what the application explicitly needs. |
| `livenessProbe` | Optional | Yes | Failure restarts the container. Tune `initialDelaySeconds` to avoid restart loops. |
| `readinessProbe` | Optional | Yes | Failure removes the pod from endpoints. Use for traffic-aware startup checks. |
| `startupProbe` | Optional | Yes | Disables `livenessProbe` and `readinessProbe` until it passes. Best for slow-starting apps. |
| `livenessProbe.httpGet` | Optional | Yes | HTTP-based liveness check. |
| `readinessProbe.httpGet` | Optional | Yes | HTTP-based readiness check. |
| `startupProbe.tcpSocket` | Optional | Yes | TCP-based startup check. |
| `initialDelaySeconds` | Optional / Important | Yes | Delay before first probe. Prevents false positives during startup. |
| `failureThreshold` | Optional | Yes | Consecutive failures before considering the container unhealthy. |
| `periodSeconds` | Optional | Yes | Frequency of probe execution. |
| `spec.hard` | Required | Yes | Defines resource quantity limits for ResourceQuota. `scopes` are optional selectors. |
| `pod-security.kubernetes.io/enforce` | Optional | Yes | Enforcement level for the namespace |
| `pod-security.kubernetes.io/warn` | Optional | Yes | Warning level for the namespace |
| `pod-security.kubernetes.io/audit` | Optional | Yes | Audit level for the namespace |
| `spec.securityContext.runAsNonRoot` | Important for Baseline/Restricted | Yes | Must be `true` |
| `spec.securityContext.runAsUser` | Important for Baseline/Restricted | Yes | Must be non-zero |
| `spec.securityContext.allowPrivilegeEscalation` | Required for Baseline/Restricted | Yes | Must be `false` |
| `spec.securityContext.readOnlyRootFilesystem` | Recommended for Restricted | Yes | Should be `true` |
| `spec.securityContext.capabilities.drop` | Required for Restricted | Yes | Must include `ALL` |
| `spec.securityContext.privileged` | Forbidden for Baseline/Restricted | Yes | Must not be `true` |
| `spec.securityContext.seccompProfile` | Recommended for Restricted | Yes | Should be `RuntimeDefault` |

```