# Services - ClusterIP - Debugging

## Common Issues

1. **Service Has No Endpoints**
   ```bash
   kubectl get endpoints web-service
   kubectl describe svc web-service
   ```
   *Root Cause*: Selector mismatch. Verify `spec.selector` matches Pod `labels` exactly.

2. **Connection Refused / Timeout from Within Pod**
   ```bash
   kubectl run tester --image=busybox --rm -it -- wget -O- http://web-service:80
   kubectl get events
   ```
   *Root Causes*: No ready Pods, probes failing, wrong namespace, or CoreDNS down.

3. **DNS Resolution Fails**
   ```bash
   kubectl run tester --image=busybox --rm -it -- nslookup web-service
   kubectl run tester --image=busybox --rm -it -- nslookup kubernetes.default
   ```
   *Root Cause*: CoreDNS Pods down, or missing `dnsPolicy`.

## Quick Fixes
- Verify labels: `kubectl get pods -l app=web`
- Verify selector: `kubectl get svc web-service -o yaml | grep selector`
