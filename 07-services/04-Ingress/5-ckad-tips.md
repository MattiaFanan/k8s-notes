# Services - Ingress - CKAD Exam Tips

## Shortcuts
- `kubectl create ingress ... --rule="host/*=svc:port"` is fast scaffolding.
- `kubectl describe ingress` shows assigned address and backend service ports.

## Pitfalls
1. **Ingress Controller Missing**: Ingress does nothing without controller. CKAD usually includes NGINX by default.
2. **Path type mismatch**: `Exact` needs exact path; use `Prefix` for broad matches.
3. **Port reference**: Ingress backend `service.port.number` must match Service `spec.ports[].port`, not `targetPort`.

## Time-Saver
```bash
alias k=kubectl
k create ingress web-ingress --class=nginx --rule="myapp/*=web-service:80"
```
