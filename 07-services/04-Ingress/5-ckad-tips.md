# Ingress - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- `kubectl create ingress ... --rule="host/*=svc:port"` is fast scaffolding.
- `kubectl describe ingress` shows assigned address and backend service ports.
- Use `kubectl get ingressclass` to list available IngressClasses.
- Use `kubectl get ingressclass <name> -o yaml` to check the default IngressClass configuration.
- Always specify `pathType` explicitly (`Prefix` or `Exact`).
- For HTTPS, create a TLS Secret of type `kubernetes.io/tls` with `tls.crt` and `tls.key` keys.

## Pitfalls
1. **Ingress Controller Missing**: Ingress does nothing without controller. CKAD usually includes NGINX by default.
2. **Path type mismatch**: `Exact` needs exact path; use `Prefix` for broad matches.
3. **Port reference**: Ingress backend `service.port.number` must match Service `spec.ports[].port`, not `targetPort`.
4. **IngressClass not set**: If no IngressClass is specified and no default exists, the Ingress may not be provisioned.
5. **TLS not configured**: If the Ingress rule uses HTTPS, TLS must be configured with a Secret containing the certificate.
6. **Trailing slash mismatch**: `Prefix` of `/api` matches `/apianything`, not just `/api/...`. Use `/api/` for directory-like paths.
7. **Exact match and trailing slash**: An `Exact` rule for `/api` does NOT match `/api/`. Add both rules or use `Prefix`.

## Time-Saver
```bash
alias k=kubectl

# Quick Ingress creation
k create ingress web-ingress --class=nginx --rule="myapp.example.com/*=web-service:80"

# Quick Ingress with TLS (TLS embedded in rule)
k create ingress web-ingress --class=nginx --rule="myapp.example.com/*=web-service:80,tls=myapp-tls-secret"

# Verify IngressClass
k get ingressclass

# Check Ingress status
k describe ingress web-ingress

# Extract path and pathType for all rules
k get ingress web-ingress -o jsonpath='{range .spec.rules[*].http.paths[*]}{.path}{"\t"}{.pathType}{"\n"}{end}'

# Patch Ingress to change pathType
k patch ingress web-ingress --type=json -p='[{"op":"replace","path":"/spec/rules/0/http/paths/0/pathType","value":"Exact"}]'
```

## Exam Patterns

### "Expose a service on a custom domain with HTTPS"
1. Create a TLS Secret of type `kubernetes.io/tls` with `tls.crt` and `tls.key`
2. Create an Ingress with `spec.tls` referencing the Secret
3. Add `spec.ingressClassName` pointing to the NGINX IngressClass
4. Add a rule with the custom hostname

### "Route / to one service and /api to another"
```yaml
spec:
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
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### "Route only the exact path /status to a health check service"
```yaml
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /status
        pathType: Exact
        backend:
          service:
            name: health-service
            port:
              number: 8080
```

## See also

- [Ingress YAML Structure](1-yaml-structure.md)
- [Ingress Core Mechanics](2-mechanics/02-core-mechanics.md)
- [Ingress TLS](2-mechanics/06-tls.md)
- [Ingress Path Types](2-mechanics/04-path-types.md)
- [Services Overview](../../0-overview.md)
