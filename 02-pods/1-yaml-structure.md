# Pods - YAML Structure & Minimal Templates

A Pod is the smallest deployable unit in Kubernetes. It represents a single instance of a running process in your cluster and encapsulates one or more containers that share storage, network, and configuration. Pods are the building blocks for higher-level controllers like Deployments and Jobs. Understanding Pod YAML is foundational because all other workload resources ultimately define Pod templates.

## Essential Pod YAML Template

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  namespace: default            # Optional: defaults to 'default' or current context
  labels:
    app: my-app                 # Crucial for Services and NetworkPolicies matching
spec:
  restartPolicy: Always         # Always | OnFailure | Never (Default: Always)
  containers:
  - name: app-container
    image: nginx:1.25           # Required container image
    imagePullPolicy: IfNotPresent # Always | IfNotPresent | Never
    command: ["sh", "-c"]       # Overrides Docker ENTRYPOINT
    args: ["echo Hello; sleep 3600"] # Overrides Docker CMD
    ports:
    - containerPort: 80         # Informational, but recommended for clarity
      name: http
    resources:
      requests:
        cpu: "100m"            # 100 millicores = 0.1 CPU
        memory: "128Mi"
      limits:
        cpu: "250m"
        memory: "256Mi"
    env:
    - name: ENV_VAR_NAME
      value: "value"
```

## Field Reference

| Field | Required / Optional / Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `metadata.name` | Required | No | Unique within namespace. Not editable after creation. Always required. |
| `metadata.namespace` | Optional | No | Defaults to `default`. Cannot be changed after creation. |
| `metadata.labels` | Optional | No | Key-value pairs for identification. Set at creation; use annotations or `kubectl label` for updates on running objects. |
| `spec.restartPolicy` | Optional | No | `Always`, `OnFailure`, or `Never`. Defaults to `Always`. Not editable after creation; recreate the Pod to change. |
| `spec.containers` | Required | – | At least one container must be defined. |
| `spec.containers[*].name` | Required | No | Unique within the Pod. Cannot be changed after creation. |
| `spec.containers[*].image` | Required | **Yes** | Container image and tag. Can be updated in a running Pod to roll to a new image version. |
| `spec.containers[*].imagePullPolicy` | Optional | No | `Always`, `IfNotPresent`, or `Never`. Best set explicitly to avoid cache issues. |
| `spec.containers[*].command` | Optional | No | Overrides Docker ENTRYPOINT. Set at creation. |
| `spec.containers[*].args` | Optional | No | Overrides Docker CMD. Set at creation. |
| `spec.containers[*].ports` | Optional | No | `containerPort` is mostly declarative/documentation. Important for Services matching (`name`) and `NetworkPolicy`. Not editable after creation. |
| `spec.containers[*].resources` | Important | No | `requests` and `limits` for CPU/memory. Immutable for running containers in many contexts; define correctly at creation. |
| `spec.containers[*].env` | Optional | No | Environment variables. Can also be supplied via `ConfigMap` or `Secret` references. Not editable after creation. |
| `spec.containers[*].volumeMounts` | Optional | No | Mount points into container filesystem. Must match a defined volume. Not editable after creation. |
| `spec.volumes` | Optional | No | Pod-level storage (emptyDir, configMap, secret, PVC, etc.). Not editable after creation. |
| `spec.activeDeadlineSeconds` | Optional | **Yes** | Hard deadline for Pod execution. Editable on running Pods (mutates `.spec`). |
| `spec.tolerations` | Optional | **Yes** | Allows Pod scheduling onto nodes with matching taints. Editable on running Pods to adjust scheduling constraints. |
