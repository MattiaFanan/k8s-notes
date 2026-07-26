# Monitoring, Logging & API Deprecations - CKAD Exam Tips

## Exam Shortcuts
- Always run `kubectl get events --sort-by=.metadata.creationTimestamp` to see newest root-cause events first.
- `kubectl describe pod` often shows probe failures and scheduling constraints more clearly than `logs`.

## Pitfalls
1. **Metrics-Server Not Installed**: `kubectl top` fails on fresh clusters unless explicitly pre-installed.
2. **Logs from Previous Container**: Use `-p` only for previously terminated containers.
3. **Old API Versions In Manifests**: CKAD usually uses current stable APIs (e.g., `apps/v1` Deployments, `batch/v1` Jobs).
4. **Forgetting `-f`**: Log streaming requires `-f`/`--follow`.

## Time-Saver
```bash
alias k=kubectl

# One-liner top + describe check
k top pod && k describe pod <pod-name> | grep -A2 'Last State'
```
