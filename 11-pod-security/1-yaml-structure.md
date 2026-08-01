# Pod Security Standards — YAML Structure

Pod Security Standards (PSS) define baseline policies for pod security. They replaced the deprecated PodSecurityPolicy (PSP) in Kubernetes 1.25. PSS are enforced via Pod Security Admission (PSA).

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

| Field | Required/Optional | Notes |
|-------|-------------------|-------|
| `pod-security.kubernetes.io/enforce` | Optional | Enforcement level for the namespace |
| `pod-security.kubernetes.io/warn` | Optional | Warning level for the namespace |
| `pod-security.kubernetes.io/audit` | Optional | Audit level for the namespace |
| `spec.securityContext.runAsNonRoot` | Important for Baseline/Restricted | Must be `true` |
| `spec.securityContext.runAsUser` | Important for Baseline/Restricted | Must be non-zero |
| `spec.securityContext.allowPrivilegeEscalation` | Required for Baseline/Restricted | Must be `false` |
| `spec.securityContext.readOnlyRootFilesystem` | Recommended for Restricted | Should be `true` |
| `spec.securityContext.capabilities.drop` | Required for Restricted | Must include `ALL` |
| `spec.securityContext.privileged` | Forbidden for Baseline/Restricted | Must not be `true` |
| `spec.securityContext.seccompProfile` | Recommended for Restricted | Should be `RuntimeDefault` |