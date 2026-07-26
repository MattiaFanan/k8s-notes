# Services - ExternalName - Debugging

## Common Issues

1. **ExternalName Not Resolving**
   ```bash
   kubectl run tester --image=busybox --rm -it -- nslookup my-db-service
   kubectl describe svc my-db-service
   ```
   *Root Cause*: External DNS name invalid, or CoreDNS cannot resolve external DNS (missing upstream).

2. **Connection Timeout**
   - *Root Cause*: External host unreachable from cluster network.
   - Check: `kubectl run tester --image=busybox --rm -it -- wget -O- http://mydb.example.com`.
