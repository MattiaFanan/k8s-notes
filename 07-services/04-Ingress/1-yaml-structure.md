# Services - Ingress - YAML Structure

An **Ingress** is a Kubernetes API object that manages external HTTP(S) access to services within the cluster. It acts as a reverse proxy, providing URL routing, TLS termination, and name-based virtual hosting based on defined rules. Ingress allows multiple services to be exposed through a single external entry point.

## Ingress Manifest

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Key Fields

| Field | Required | Notes |
| :--- | :---: | :--- |
| `spec.rules[].host` | Conditional | Required if exposing by domain. |
| `spec.rules[].http.paths[].path` | Yes | URL path regex/prefix. |
| `spec.rules[].http.paths[].pathType` | Yes | `Prefix`, `Exact`, `ImplementationSpecific`. Required; no default in networking.k8s.io/v1. |
| `spec.ingressClassName` | Conditional | Required if cluster has default ingress class configured. |

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
| :--- | :--- | :---: | :--- |
| `spec.ingressClassName` | Important | Yes | Selects the ingress controller. Required when the cluster has a default ingress class configured but you want to use a specific one. |
| `spec.rules[]` | Optional | Yes | An array of routing rules. Each rule defines a host and set of paths. |
| `spec.rules[].host` | Optional | Yes | FQDN for the rule. Commonly used to enable name-based virtual hosting (e.g. `myapp.example.com`). |
| `spec.rules[].http.paths[].path` | Required | Yes | URL path pattern matched by the ingress. |
| `spec.rules[].http.paths[].pathType` | Required | Yes | Must be one of `Prefix`, `Exact`, or `ImplementationSpecific`. `Prefix` is the most common choice. |
| `spec.rules[].http.paths[].backend.service.port.number` | Required | Yes | References the **Service port** (not `targetPort`). Must match the port defined in the referenced Service. |
| `spec.tls` | Optional | Yes | An array of TLS configurations for HTTPS termination. Each entry defines hosts and a secret for the TLS certificate. |
| `metadata.annotations` | Important | Yes | Controller-specific annotations (e.g. `nginx.ingress.kubernetes.io/rewrite-target`). Syntax and supported keys depend on the ingress controller in use. |
| `spec.defaultBackend` | Optional | Yes | A fallback backend for requests that do not match any rule. Useful for catching unmatched paths. |
