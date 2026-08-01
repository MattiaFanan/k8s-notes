# Monitoring, Logging & API Deprecations - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Shortcuts
- Always run `kubectl get events --sort-by=.metadata.creationTimestamp` to see newest root-cause events first.
- `kubectl describe pod` often shows probe failures and scheduling constraints more clearly than `logs`.
- Use `kubectl debug` with ephemeral containers for non-disruptive debugging.
- A misconfigured readiness probe is the most common reason a "correct" Deployment task still fails the grader.

## Pitfalls
1. **Metrics-Server Not Installed**: `kubectl top` fails on fresh clusters unless explicitly pre-installed.
2. **Logs from Previous Container**: Use `-p` only for previously terminated containers.
3. **Old API Versions In Manifests**: CKAD usually uses current stable APIs (e.g., `apps/v1` Deployments, `batch/v1` Jobs).
4. **Forgetting `-f`**: Log streaming requires `-f`/`--follow`.
5. **Liveness probe checking external dependencies**: Causes unnecessary restarts when the dependency is temporarily unavailable.
6. **`initialDelaySeconds` too short**: Causes false liveness failures on slow-start apps.

## Time-Saver
```bash
alias k=kubectl

# One-liner top + describe check
k top pod && k describe pod <pod-name> | grep -A2 'Last State'

# Full debugging session
k describe pod mypod -n myns
k logs mypod -n myns
k logs mypod -n myns -p
k top pod mypod -n myns
k get events -n myns --field-selector involvedObject.name=mypod --sort-by='.lastTimestamp'
k debug mypod -n myns --image=busybox -it -- sh
```

## See also

- [Observability Tools](2-mechanics/04-observability-tools.md)
- [Probe Behavior](2-mechanics/03-probes-behavior.md)
- [Health Probes Recap](2-mechanics/02-health-probes-recap.md)
- [Debugging Workflow](2-mechanics/05-debugging-workflow.md)
- [Ephemeral Containers](2-mechanics/06-ephemeral-containers.md)
