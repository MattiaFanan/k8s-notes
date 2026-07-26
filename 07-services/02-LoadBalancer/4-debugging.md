# Services - LoadBalancer - Debugging

## Common Issues

1. **External IP Pending**
   ```bash
   kubectl describe svc web-service
   kubectl get nodes -o wide
   ```
   *Root Causes*: Cloud CCM not running, no floating IP quota, or metadata server blocked in bare-metal.

2. **Health Check Failing**
   - Cloud LB checks NodePort; if backend Pods not ready, health check fails.
   - Verify `readinessProbe` on backend Pods.

3. **502/503 Errors**
   - Check `kubectl get endpoints web-service` for healthy backends.
   - Review cloud provider load balancer logs.
