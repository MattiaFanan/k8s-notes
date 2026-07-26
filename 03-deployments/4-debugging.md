# Deployments & Workloads - Debugging

## Common Deployment Issues & Troubleshooting

1. **Stuck Rollout**:
   ```bash
   kubectl rollout status deployment/my-dep
   kubectl describe deployment/my-dep
   ```
   *Common Cause*: Pods in new ReplicaSet failing liveness/readiness probes, or `ImagePullBackOff`.

2. **Mismatched Label Selectors**:
   - Error: `selector does not match template labels`.
   - Fix: Ensure `spec.selector.matchLabels` matches `spec.template.metadata.labels` exactly.

3. **Job Failures**:
   ```bash
   kubectl describe job <job-name>
   kubectl get pods --selector=job-name=<job-name>
   ```
   *Common Cause*: Non-zero exit codes, exceeding `activeDeadlineSeconds` or `backoffLimit`.

4. **CronJob Not Executing**:
   - Verify cluster time / controller manager time zone.
   - Check if previous execution is stuck and `concurrencyPolicy: Forbid` is set.
