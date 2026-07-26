# Multi-Container Pods - Debugging

## Common Issues

1. **Init Container Not Proceeding**
   ```bash
   kubectl get pod <pod-name> -o wide
   kubectl describe pod <pod-name>
   ```
   *Root Cause*: Init container command failing (DNS, permission, or dependency errors).

2. **Shared Volume Not Populated**
   *Root Cause*: Volume mount paths mismatched, or volume name incorrectly shared.

3. **Sidecar Not Running**
   ```bash
   kubectl logs <pod-name> -c <sidecar-name>
   kubectl exec -it <pod-name> -c <main-container> -- ls /etc/shared
   ```
   *Root Cause*: Image pull issues, or volume mounts conflicting.

## Diagnostic Steps
- Check init container state with `kubectl get pod` before checking app containers.
- Inspect all containers with `-c` without needing to know which container failed.
