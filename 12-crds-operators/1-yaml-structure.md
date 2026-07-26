# CRDs & Operators - YAML Structure

Custom Resource Definitions (CRDs) let you extend Kubernetes with custom resource types, and Operators use custom resources to automate complex application lifecycle management. A CRD defines the schema and group for a new resource kind, while a custom resource is an instance of that kind. Operators typically run as Deployments that watch for custom resources and reconcile the desired state. The examples below show a CRD definition, a custom resource instance, and a simple operator Deployment.

## CustomResourceDefinition (CRD)

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              cronSpec:
                type: string
              image:
                type: string
              replicas:
                type: integer
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
```

## Custom Resource (Instance of CRD)

```yaml
apiVersion: stable.example.com/v1
kind: CronTab
metadata:
  name: my-new-cron
spec:
  cronSpec: "* * * * *"
  image: my-company/my-cron-image
  replicas: 3
```

## Operator Example: Deployment-Based Operator

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-operator
  template:
    metadata:
      labels:
        app: my-operator
    spec:
      containers:
  - name: operator
        image: my-operator:1.0
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| CRD `spec.group` | Required | Yes | DNS label for the API group (e.g. `stable.example.com`). Must be a valid RFC 1123 subdomain. |
| CRD `spec.versions[].name` | Required | Yes | Version identifier (e.g. `v1`). Multiple versions can be served simultaneously. |
| CRD `spec.versions[].served` | Required | Yes | Must be `true` for the version to be served by the API server. |
| CRD `spec.versions[].storage` | Required | Yes | Exactly one version must have `storage: true`. Determines which version persists etcd data. |
| CRD `spec.versions[].schema` | Important | Yes | Contains the `openAPIV3Schema` used for CR validation and pruning. |
| CRD `spec.scope` | Required | Yes | Either `Namespaced` or `Cluster`. Determines whether CRs live in a namespace or at cluster scope. |
| CRD `spec.names.plural` | Required | Yes | Plural name used in the API path (e.g. `crontabs`). Must be a valid DNS subdomain. |
| CRD `spec.names.singular` | Required | Yes | Singular name used in display and some CLI outputs (e.g. `crontab`). |
| CRD `spec.names.kind` | Required | Yes | The kind name used in manifests (e.g. `CronTab`). Typically CamelCase. |
| CRD `spec.names.shortNames` | Optional | Yes | Abbreviated names for CLI convenience (e.g. `ct`). |
| CRD `spec.conversionStrategy` | Optional | Yes | `Webhook` or `None`. Use `Webhook` when you need version conversion; `None` keeps a single internal version. |
| CR `apiVersion` | Required | Yes | Must match `<group>/<version>` (e.g. `stable.example.com/v1`). Changing this may require updating selectors and RBAC. |
| CR `kind` | Required | Yes | Must match the CRD `spec.names.kind` (e.g. `CronTab`). |
| CR `metadata.name` | Required | Yes | The unique identifier for the custom resource instance within its scope. |
| CR `spec` | Required | Yes | Must conform to the `openAPIV3Schema` defined in the CRD. Invalid specs are rejected by the API server. |
| Operator Deployment | Required for operator functionality | Yes | Runs the controller process that watches CRs and reconciles state. Ensure it has appropriate RBAC and leader-election settings for HA. |
| Orphaned CR pruning | Important | No (cluster config) | Orphaned CRs can remain after CRD deletion. Enable cascading deletion via `cascading deletion` or finalizers to prevent stale CRs. |