# Services - NodePort - Debugging

## Common Issues

1. **Connection Refused/Timeout on NodePort**
   ```bash
   kubectl describe svc web-service
   kubectl get endpoints web-service
   kubectl get nodes -o wide
   ```
   *Root Cause*: Firewall blocking node port, cloud security group restrictions, or empty endpoints.

2. **All Requests Hit Same Node (Load Balancing)**
   - `externalTrafficPolicy: Cluster` distributes across all nodes.
   - `externalTrafficPolicy: Local` only uses local node Pods.

3. **NodePort Not Available**
   - Check if requested port is already in use or outside range.
   - Omit `nodePort` for auto-assignment.
