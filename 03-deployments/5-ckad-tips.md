# Deployments & Workloads - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## Exam Speed Shortcuts

- Always use `kubectl set image` for quick updates during exam questions instead of manually editing YAML.
- Use `kubectl create deployment web --image=nginx --dry-run=client -o yaml > deploy.yaml` to quickly scaffold deployments.
- Remember `kubectl rollout undo` for instant rollback when an update breaks.
- Use `kubectl rollout status deployment/<name>` to monitor rollout progress.
- Use `kubectl rollout history deployment/<name>` to see revision history.
- Use `kubectl rollout undo deployment/<name> --to-revision=N` to rollback to a specific revision.

## Key Checklist & Pitfalls

- **Job Restart Policy**: Pods managed by Jobs MUST set `restartPolicy: OnFailure` or `Never`. `Always` will fail validation!
- **Match Labels**: Deployments created with `kubectl create deployment` automatically set `app=<name>` matchLabels. If modifying manually, do not break label alignment.
- **CronJob `startingDeadlineSeconds`**: If a CronJob misses its scheduled time (e.g., cluster was down), it will run only if the deadline has not yet passed; otherwise, the run is skipped. Default is not set (no deadline).
- **Job `ttlSecondsAfterFinished`**: Set this to automatically clean up completed Jobs and their Pods. Without it, completed Jobs accumulate in etcd.
- **Deployment `selector` is immutable**: You cannot change `spec.selector` after creating a Deployment. Ensure labels match `spec.template.metadata.labels`.
- **`maxUnavailable: 0` + `maxSurge: 0` is a deadlock**: The Deployment controller cannot make progress. Never set both to 0 for RollingUpdate.
- **PDB interaction**: PDBs do not apply to Deployment rolling updates. They only govern voluntary evictions (e.g., `kubectl drain`).

## Time-Saver

```bash
alias k=kubectl

# Quick deployment with rollout monitoring
k create deployment web --image=nginx:1.25 --replicas=3 --dry-run=client -o yaml > deploy.yaml
k apply -f deploy.yaml
k rollout status deployment/web

# Quick rollback
k rollout undo deployment/web
k rollout undo deployment/web --to-revision=2

# Quick image update + rollout check
k set image deployment/web nginx=nginx:1.26
k rollout status deployment/web
```

## See also

- [Deployments YAML Structure](1-yaml-structure.md)
- [Deployment Strategies](2-mechanics/02-deployment-strategies.md)
- [PodDisruptionBudgets](2-mechanics/05-pdb-and-strategies.md)
- [Jobs & CronJobs](2-mechanics/03-job-cronjob-behavior.md)
