# Ingress - Common CKAD Patterns

This guide covers the most frequently tested Ingress patterns in the CKAD exam and real-world cluster administration. Mastering these patterns is essential for the CKAD certification and for day-to-day ingress management.

## Single Domain, Multiple Path Routing

The most common CKAD scenario: a single Ingress resource routes different URL paths to different backend Services. This pattern is used when one domain hosts multiple microservices.

### How It Works

```mermaid
flowchart TD
    A["Client Request\nhttps://example.com"] --> B["Ingress Controller\n(NGINX/Traefik)"]
    B --> C{"URL Path\nMatcher"}
    C -->| "/"  | D["web-svc\nClusterIP:80"]
    C -->| "/api" | E["api-svc\nClusterIP:8080"]
    C -->| "/static" | F["assets-svc\nClusterIP:8081"]
    D --> G["web pods"]
    E --> H["api pods"]
    F --> I["assets pods"]
```

### Concrete Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
          - path: /static
            pathType: Prefix
            backend:
              service:
                name: static-assets-svc
                port:
                  number: 8081
```

### kubectl Commands

```bash
# Apply the Ingress resource
kubectl apply -f ingress-multipath.yaml

# Verify the Ingress was created and has an address assigned
kubectl get ingress example-ingress -n production -o wide

# Describe the Ingress to see events and status conditions
kubectl describe ingress example-ingress -n production

# Check the IngressClass being used
kubectl get ingressclass nginx -o yaml

# Test routing from within the cluster
kubectl run -n production curl-test --image=curlimages/curl --rm -it --restart=Never -- \
  curl -s http://example.com/ && echo "---" && \
  curl -s http://example.com/api/health
```

## Host-Based Routing Across Multiple Domains

When different subdomains map to different backend Services, host-based routing is the answer. This pattern is common for multi-tenant or multi-product setups behind a single IP.

### How It Works

```mermaid
flowchart TD
    A["Client Request"] --> B{"Host Header\nMatcher"}
    B -->| app1.example.com | C["ingress-controller\nroutes to app1-svc"]
    B -->| app2.example.com | D["ingress-controller\nroutes to app2-svc"]
    B -->| "default (no match)" | E["default-backend\n(404 or custom)"]
    C --> F["app1 pods"]
    D --> G["app2 pods"]
```

### Concrete Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-host-ingress
  namespace: production
spec:
  ingressClassName: nginx
  rules:
    - host: app1.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app1-service
                port:
                  number: 80
    - host: app2.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app2-service
                port:
                  number: 80
```

### kubectl Commands

```bash
# Apply
kubectl apply -f ingress-multihost.yaml

# Verify routing rules are present
kubectl get ingress multi-host-ingress -n production -o jsonpath='{.spec.rules[*].host}'

# Check which controller is handling this Ingress
kubectl get ingress multi-host-ingress -n production -o jsonpath='{.spec.ingressClassName}'

# Test from a temporary pod in the cluster
kubectl run -n production host-test --image=curlimages/curl --rm -it --restart=Never -- \
  curl -s -H "Host: app1.example.com" http://<INGRESS-IP>/ && echo "" && \
  curl -s -H "Host: app2.example.com" http://<INGRESS-IP>/
```

## Combining Host and Path Rules

CKAD exams frequently test combined host + path routing, where different hosts have different path hierarchies.

### Concrete Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: combined-ingress
  namespace: production
spec:
  ingressClassName: nginx
  rules:
    - host: shop.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: shop-fe-svc
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: shop-api-svc
                port:
                  number: 8080
    - host: admin.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: admin-panel-svc
                port:
                  number: 3000
```

## Best Practices and Community Knowledge

1. **Always set `pathType` explicitly** — `ImplementationSpecific` is the default for older Ingress versions, but it can produce inconsistent behavior across controllers. Use `Prefix` or `Exact` explicitly.

2. **Order of paths matters for `Prefix` matching** — NGINX Ingress sorts paths by length (longest first) among `Prefix` rules, which avoids most overlap issues. However, an `Exact` match always takes precedence over `Prefix` matches regardless of order.

3. **Use annotations sparingly and deliberately** — Ingress annotations are controller-specific and not portable. If you standardize on one controller (e.g., NGINX), document your annotation catalog.

4. **Always specify `ingressClassName`** — Starting with Kubernetes 1.18+, omitting `ingressClassName` causes ambiguity if multiple controllers are installed. Setting it explicitly ensures deterministic behavior.

5. **Backend Services must exist before the Ingress** — If a referenced Service doesn't exist, the Ingress will not route traffic to it. Endpoints will be empty and requests will return 503 or connection errors.

## Common Pitfalls and Troubleshooting

- **Ingress is created but no external IP is assigned**: The Ingress controller Deployment or Service is likely not running. Check `kubectl get pods -n <ingress-namespace>` and the controller's Service type is `LoadBalancer` or `NodePort`.

- **502/503 Bad Gateway**: The backend Service endpoints are empty or the pods are not ready. Run `kubectl get endpoints <service-name>` and `kubectl describe pod <pod-name>` to diagnose.

- **Traffic not matching expected path**: Verify `pathType` is set correctly. `Prefix` matches path prefixes; `Exact` requires a full match. Check that the request URL matches the rule exactly, including trailing slashes.

- **TLS not terminating**: Ensure the Secret referenced in `spec.tls[].secretName` exists in the same namespace and contains `tls.crt` and `tls.key` keys. Run `kubectl get secret <secret-name> -o jsonpath='{.data}' | jq` to verify key presence.

- **Host-based routing not working with HTTP**: The client must send the correct `Host` header. Browsers set this automatically via the URL; tools like `curl` default to the IP, so you must pass `-H "Host: hostname"`.

- **`defaultBackend` not returning expected response**: Check that the Ingress controller's default backend is configured if you expect a custom default response for unmatched paths.

## Exam Strategy

- When a CKAD question asks you to expose multiple apps on a single IP, reach for an Ingress resource with multiple rules.
- If the question mentions a specific ingress controller (NGINX, Traefik), check for required annotations and IngressClass.
- Always verify that referenced Services exist in the same namespace and have correct selector/port definitions — the Ingress is only the routing layer, not the service discovery layer.