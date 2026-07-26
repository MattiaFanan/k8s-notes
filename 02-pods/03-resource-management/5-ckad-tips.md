# Resource Management - CKAD Exam Tips

## Exam Shortcuts
- Always set both requests and limits when asked for "resources".
- Prefer binary units: `100m`, `128Mi`, `1Gi`.

## Pitfalls
1. **Decimal CPU**: Never write `0.1` CPU; use `100m`.
2. **No Quota by Default**: ResourceQuota does not exist unless explicitly created.
3. **Requests Drive Scheduling**: Omitting requests can cause scheduling unpredictability.

## Time-Saver
```bash
# Patch multiple containers quickly
kubectl patch pod mypod -p '{"spec":{"containers":[{"name":"c1","resources":{"requests":{"cpu":"100m"}}},{"name":"c2","resources":{"requests":{"cpu":"100m"}}}]}}'
```

## Checklist
- Verify `kubectl top pod` if performance seems wrong (metrics-server must be running).
- Verify `describe pod` for `OOMKilled` or `Exited` with non-zero code when Pod fails.
