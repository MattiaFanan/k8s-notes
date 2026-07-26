# Pods - Debugging & Troubleshooting

## Diagnostic Checklist

1. **Check Status & Events**:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   kubectl get events --sort-by=.metadata.creationTimestamp
   ```

2. **Check Logs**:
   ```bash
   # Current logs
   kubectl logs <pod-name>
   
   # Multi-container pod
   kubectl logs <pod-name> -c <container-name>
   
   # Previously crashed container logs
   kubectl logs <pod-name> -p
   ```

3. **Interactive Debugging**:
   ```bash
   kubectl exec -it <pod-name> -- sh
   ```

## Common Pod Failure Modes

| Error / State | Common Root Cause | Quick Remediation |
| :--- | :--- | :--- |
| `ImagePullBackOff` / `ErrImagePull` | Typos in image name/tag, private registry auth missing | Fix image name in YAML or create imagePullSecret |
| `CrashLoopBackOff` | Application crashes on startup, wrong entrypoint/command | Check `kubectl logs <pod> -p`, verify command/args |
| `Pending` | Insufficient CPU/Memory on nodes, unsatisfied nodeSelector/Taints | Run `kubectl describe pod` to check events/unschedulable reasons |
| `OOMKilled` (Exit Code 137) | Container exceeded memory limits | Increase `resources.limits.memory` in Pod spec |
| `CreateContainerConfigError` | Missing ConfigMap/Secret referenced in `envFrom` or `env` | Create missing ConfigMap/Secret or fix key references |
