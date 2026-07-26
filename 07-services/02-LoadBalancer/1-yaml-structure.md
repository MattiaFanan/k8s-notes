# Services - LoadBalancer - YAML Structure

A **LoadBalancer** service provisions an external load balancer in the cloud provider to route traffic to the application. It extends the NodePort type by automatically creating a cloud load balancer and assigning an external IP address. This is the standard way to expose services externally in managed Kubernetes environments.

## Service Manifest (LoadBalancer)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
spec:
  type: LoadBalancer
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
| `spec.type` | No | Set to `LoadBalancer` for external cloud load balancer provisioning. |
| `spec.ports[].port` | Yes | External-facing port. |
| `spec.ports[].targetPort` | Yes | Container port on Pod. |
| `metadata.annotations` | Conditional | Cloud-specific config (e.g., AWS NLB, GCP TCP proxy). |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :--- | :--- |
| `spec.type` | Required | Yes | Must be `LoadBalancer`. Triggers cloud CCM to provision an external load balancer. |
| `metadata.name` | Required | Yes | Service name used for DNS discovery within the cluster. |
| `spec.selector` | Important | No (immutable) | Labels used to select target Pods. Immutable after creation; changing requires deleting and recreating the Service. |
| `spec.ports[].port` | Required | Yes | The external port exposed by the Service. |
| `spec.ports[].targetPort` | Required | Yes | The port on which the container is listening inside the Pod. |
| `spec.ports[].nodePort` | Optional | Yes | If omitted, Kubernetes assigns one dynamically. Only needed for fixed port requirements. |
| `metadata.annotations` | Important | Yes | Cloud-specific configuration (e.g., `service.beta.kubernetes.io/aws-load-balancer-type: nlb`). |
| `spec.externalIPs` | Optional | Yes | Additional IPs to route to the Service; does not replace the cloud-assigned external IP. |
| `spec.loadBalancerIP` | Optional | Yes | Requests a specific external IP; only honored if supported by the cloud provider. |
| `spec.loadBalancerSourceRanges` | Optional | Yes | Restricts traffic to the specified CIDR ranges (e.g., `["0.0.0.0/0"]`). |
| `spec.sessionAffinity` | Optional | Yes | Set to `ClientIP` for sticky sessions or `None` for round-robin. |
| `status.loadBalancer.ingress[].ip` | Automatic | No | External IP assigned asynchronously by the cloud provider's CCM. Not directly configurable. |
