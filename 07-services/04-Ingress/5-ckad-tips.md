# Services - Ingress - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Shortcuts
- `kubectl create ingress ... --rule="host/*=svc:port"` is fast scaffolding.
- `kubectl describe ingress` shows assigned address and backend service ports.
- Use `kubectl get ingressclass` to list available IngressClasses.
- Use `kubectl get ingressclass <name> -o yaml` to check the default IngressClass configuration.

## Pitfalls
1. **Ingress Controller Missing**: Ingress does nothing without controller. CKAD usually includes NGINX by default.
2. **Path type mismatch**: `Exact` needs exact path; use `Prefix` for broad matches.
3. **Port reference**: Ingress backend `service.port.number` must match Service `spec.ports[].port`, not `targetPort`.
4. **IngressClass not set**: If no IngressClass is specified and no default exists, the Ingress may not be provisioned.
5. **TLS not configured**: If the Ingress rule uses HTTPS, TLS must be configured with a Secret containing the certificate.

## Time-Saver
```bash
alias k=kubectl
k create ingress web-ingress --class=nginx --rule="myapp/*=web-service:80"

# Verify IngressClass
k get ingressclass

# Check Ingress status
k describe ingress web-ingress
```

## See also

- [Ingress YAML Structure](1-yaml-structure.md)
- [Ingress Core Mechanics](2-mechanics/02-core-mechanics.md)
- [Ingress TLS](2-mechanics/06-tls.md)
- [Services Overview](../../0-overview.md)
