# Admission Control, Authentication & Authorization - YAML Structure

Admission controllers intercept requests to the Kubernetes API server before objects are persisted, allowing validation or mutation of resources. Webhook-based admission uses ValidatingWebhookConfiguration and MutatingWebhookConfiguration objects to call external services. This file covers the YAML structure for admission webhooks, service account tokens, and image pull secrets used in authentication and authorization flows.

## ServiceAccount Token Request

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: default-token-abc123
  annotations:
    kubernetes.io/service-account.name: default
    kubernetes.io/service-account.uid: uid-here
type: kubernetes.io/service-account-token
```

## ValidatingWebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: object-validator
webhooks:
- name: object-validator.example.com
  rules:
  - apiGroups: [""]
    apiVersions: ["v1"]
    operations: ["CREATE"]
    resources: ["pods"]
  clientConfig:
    service:
      namespace: default
      name: validator-svc
      path: /validate
    caBundle: <base64-ca-bundle>
  admissionReviewVersions: ["v1"]
  sideEffects: None
  timeoutSeconds: 5
```

## MutatingWebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: pod-mutator
webhooks:
- name: pod-mutator.example.com
  rules:
  - apiGroups: [""]
    apiVersions: ["v1"]
    operations: ["CREATE"]
    resources: ["pods"]
  clientConfig:
    service:
      namespace: default
      name: mutator-svc
      path: /mutate
    caBundle: <base64-ca-bundle>
  admissionReviewVersions: ["v1"]
  sideEffects: None
```

## ImagePullSecret Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  imagePullSecrets:
  - name: my-registry-cred
  containers:
  - name: app
    image: my-private-registry.com/app:1.0
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `automountServiceAccountToken` | Important | Yes | Controls whether a ServiceAccount token is automatically mounted into pods. Set to `false` when tokens are not needed to reduce attack surface. |
| `rules` (webhook) | Required | Yes | Defines which API resources, groups, versions, and operations the webhook intercepts. To match all resources, use wildcards (`apiGroups: ["*"]`, `apiVersions: ["*"]`, `operations: ["*"]`, `resources: ["*"]`). |
| `clientConfig.service.namespace` | Required | Yes | Namespace of the webhook service. Must match the service hosting the admission webhook endpoint. |
| `clientConfig.service.name` | Required | Yes | Name of the Kubernetes Service that routes traffic to the webhook pod. |
| `clientConfig.service.path` | Optional | Yes | URL path on the service to forward requests to (e.g., `/validate`, `/mutate`). Defaults to `/`. |
| `clientConfig.caBundle` | Required | Yes | Base64-encoded CA certificate used to verify the webhook server's TLS certificate. |
| `admissionReviewVersions` | Required | Yes | List of `AdmissionReview` versions the webhook supports. `v1` is recommended for K8s 1.16+. |
| `sideEffects` | Required | Yes | Must be `None` or `NoneOnDryRun` for K8s 1.16+. Indicates whether the webhook has side effects; `Unknown` is not allowed. |
| `timeoutSeconds` | Optional | Yes | Webhook timeout in seconds (1–30). Default is 10. Exceeding the timeout causes the API server to fail-closed or fail-open based on `failurePolicy`. |
| `failurePolicy` | Important | Yes | `Ignore` allows the request to proceed if the webhook fails; `Fail` rejects the request. Use `Fail` for security-critical webhooks. |
| `reinvocationPolicy` | Optional | Yes | `Never` (default) means the webhook is called once per request; `IfNeeded` allows reinvocation if the object is mutated by another webhook. |
| `imagePullSecrets` | Optional | Yes | References a Secret of type `kubernetes.io/dockerconfigjson` containing registry credentials. Used in Pod specs to pull images from private registries. |
| CCM (Cloud Controller Manager) | Important | N/A | Separates cloud provider logic from the core Kubernetes control plane, allowing cloud-specific controllers to run as pods. |
| CSI (Container Storage Interface) | Important | N/A | Standardizes storage driver implementations, enabling pluggable storage backends without modifying core Kubernetes code. |
