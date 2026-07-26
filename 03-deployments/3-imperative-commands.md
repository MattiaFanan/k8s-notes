# Deployments & Workloads - Imperative Commands & Management

## Deployment Commands

```bash
# Generate Deployment YAML
kubectl create deployment my-dep --image=nginx:1.25 --replicas=3 --dry-run=client -o yaml > deploy.yaml

# Scale Deployment
kubectl scale deployment my-dep --replicas=5

# Update Container Image
kubectl set image deployment/my-dep nginx=nginx:1.26

# Rollout Status & History
kubectl rollout status deployment/my-dep
kubectl rollout history deployment/my-dep

# Rollback Deployment
kubectl rollout undo deployment/my-dep
kubectl rollout undo deployment/my-dep --to-revision=2

# Pause & Resume Rollout
kubectl rollout pause deployment/my-dep
kubectl rollout resume deployment/my-dep
```

## Job & CronJob Commands

```bash
# Create Job
kubectl create job my-job --image=busybox -- sh -c "echo Job complete"

# Create CronJob
kubectl create cronjob my-cron --image=busybox --schedule="*/5 * * * *" -- sh -c "date"

# Manually trigger job from CronJob
kubectl create job --from=cronjob/my-cron manual-job
```
