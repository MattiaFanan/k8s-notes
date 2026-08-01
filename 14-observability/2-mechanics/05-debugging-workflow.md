# Systematic Debugging Workflow

A structured approach to debugging Kubernetes workloads. Follow this workflow to efficiently diagnose and resolve issues.

## Phase 1: Identify the Problem

### Check Pod Status

```bash
# Get pod status
kubectl get pods -n myns

# Look for:
# - CrashLoopBackOff: container is crashing repeatedly
# - ImagePullBackOff: image cannot be pulled
# - Pending: pod not scheduled or image not pulled
# - Error/Failed: container exited with non-zero code
# - Completed: pod finished successfully (Jobs)
```

### Check Pod Events

```bash
# Get events for a specific pod
kubectl describe pod mypod -n myns | grep -A 20 "Events:"

# Get recent events in namespace
kubectl get events -n myns --sort-by='.metadata.creationTimestamp' | tail -20

# Get warning events only
kubectl get events -n myns --field-selector type=Warning
```

### Check Container Logs

```bash
# Current logs
kubectl logs mypod -n myns

# Previous container logs (after crash)
kubectl logs mypod -n myns -p

# Specific container logs
kubectl logs mypod -n myns -c container-name

# Stream logs
kubectl logs mypod -n myns -f

# Last N lines
kubectl logs mypod -n myns --tail=100
```

## Phase 2: Diagnose the Root Cause

### Check Resource Usage

```bash
# Pod resource usage
kubectl top pod mypod -n myns

# Node resource usage
kubectl top nodes

# Check if pod is OOMKilled
kubectl describe pod mypod -n myns | grep -i "oom\|kill\|exit"
```

### Check Scheduling Issues

```bash
# Check why pod is not scheduled
kubectl describe pod mypod -n myns | grep -i "schedule\|taint\|affinity"

# Check node taints
kubectl describe node <node-name> | grep -A5 Taints

# Check node resources
kubectl describe node <node-name> | grep -A10 "Allocated resources"
```

### Check Probes

```bash
# Check probe status
kubectl describe pod mypod -n myns | grep -A 20 "Liveness\|Readiness\|Startup"

# Check if pod is ready
kubectl get pod mypod -n myns -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'

# Check container state
kubectl describe pod mypod -n myns | grep -A 10 "State:"
```

### Check Volume Mounts

```bash
# Check volume mount status
kubectl describe pod mypod -n myns | grep -A 10 "Mounts\|Volumes"

# Check PVC binding status
kubectl get pvc -n myns
kubectl describe pvc mypvc -n myns
```

### Check Network Connectivity

```bash
# Test DNS resolution from inside a pod
kubectl exec mypod -n myns -- nslookup my-svc.my-namespace.svc.cluster.local

# Test HTTP connectivity
kubectl exec mypod -n myns -- curl -s http://my-svc.my-namespace.svc.cluster.local/healthz

# Test connectivity to external host
kubectl exec mypod -n myns -- curl -s --connect-timeout 3 https://example.com
```

## Phase 3: Fix the Problem

### Common Fixes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| CrashLoopBackOff | App crash on startup | Check logs, fix config, increase `initialDelaySeconds` |
| ImagePullBackOff | Wrong image name/tag | Verify image name, tag, and registry credentials |
| Pending | Insufficient resources or taints | Check node resources, taints, tolerations |
| OOMKilled | Memory limit too low | Increase memory limit |
| Readiness probe failing | Dependency not ready | Check dependency health, increase `initialDelaySeconds` |
| Liveness probe failing | App hung or slow | Check app health, increase `failureThreshold` |
| Permission denied | Volume permissions | Add `fsGroup` to pod security context |
| Read-only filesystem | `readOnlyRootFilesystem: true` | Mount `emptyDir` at writable paths |
| DNS resolution fails | NetworkPolicy blocking port 53 | Allow DNS egress in NetworkPolicy |
| Service not receiving traffic | Pod not ready | Check readiness probe and pod conditions |

### Apply Fix and Verify

```bash
# Apply the fix
kubectl apply -f fixed-manifest.yaml -n myns

# Verify the pod is running
kubectl get pod mypod -n myns

# Verify readiness
kubectl get pod mypod -n myns -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
# Expected: True

# Verify logs are healthy
kubectl logs mypod -n myns --tail=20
```

## Phase 4: Prevent Recurrence

1. **Add proper probes**: Ensure liveness, readiness, and startup probes are configured.
2. **Set resource limits**: Prevent OOMKill and CPU throttling.
3. **Use PodDisruptionBudgets**: Protect against voluntary disruptions.
4. **Monitor with alerts**: Set up alerts for CrashLoopBackOff, OOMKilled, and ImagePullBackOff.
5. **Use Pod Security Standards**: Prevent insecure configurations.

## Quick Reference: kubectl Debug Commands

```bash
# Full debugging session
kubectl describe pod mypod -n myns
kubectl logs mypod -n myns
kubectl logs mypod -n myns -p
kubectl top pod mypod -n myns
kubectl get events -n myns --field-selector involvedObject.name=mypod

# Ephemeral debug container
kubectl debug mypod -n myns --image=busybox -it -- sh

# Port-forward for debugging
kubectl port-forward pod/mypod 8080:80 -n myns
```

## See also

- [Pods - CKAD Tips](../../02-pods/5-ckad-tips.md)
- [Observability Tools](04-observability-tools.md)
- [Probe Behavior](03-probes-behavior.md)