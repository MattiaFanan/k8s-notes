# Services - Ingress - Debugging

## Common Issues

1. **Ingress Has No Address**
   ```bash
   kubectl describe ingress web-ingress
   kubectl get pods -n ingress-nginx
   ```
   *Root Cause*: Ingress Controller not running, or controller lacks LoadBalancer support.

2. **404/503 from Ingress**
   ```bash
   kubectl describe ingress web-ingress
   kubectl get svc web-service
   ```
   *Root Cause*: Backend Service name/port wrong, or backend Pods unhealthy.

3. **TLS Not Working**
   - Verify Secret exists and `tls.secretName` references correct Secret.
   - Verify Secret contains `tls.crt` and `tls.key`.

## Diagnostic Commands
```bash
kubectl get ingress -o wide
kubectl describe ingress web-ingress
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get pods -n ingress-nginx
```
