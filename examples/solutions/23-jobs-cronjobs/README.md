# 23 – Solution

Imperative skeletons (then add the extra fields):
```bash
kubectl create job batch -n jobs-23 --image=busybox:1.36 --dry-run=client -o yaml -- sh -c 'echo processed by $HOSTNAME; sleep 2' > batch.yaml
kubectl create cronjob reporter -n jobs-23 --image=busybox:1.36 --schedule='*/5 * * * *' --dry-run=client -o yaml -- sh -c 'date; echo report done' > cj.yaml
kubectl apply -f jobs.yaml
kubectl create job reporter-manual --from=cronjob/reporter -n jobs-23      # step 5
kubectl get jobs,pods -n jobs-23 -w
kubectl describe job failer -n jobs-23        # Warning BackoffLimitExceeded: Job has reached the specified backoff limit
```

## Key points
- **completions** = how many successes, **parallelism** = how many pods at once. Neither set = 1 pod.
  Only parallelism set = a work queue: done when one pod succeeds and the rest stop.
- **backoffLimit** counts pod failures (retries use exponential back-off: 10s, 20s, 40s...). **activeDeadlineSeconds** ends
  the Job after that time whatever the retries (reason `DeadlineExceeded`).
- `restartPolicy: Never` = every failure is a new pod (you keep the logs). `OnFailure` = the container restarts in the same pod.
- **Indexed** jobs get `JOB_COMPLETION_INDEX` (also in the annotation `batch.kubernetes.io/job-completion-index`), so each pod
  can process "its" slice of the work.
- **CronJob** fields live at two levels: `schedule`, `concurrencyPolicy`, history limits and `startingDeadlineSeconds` are on the CronJob.
  The pod lives under `jobTemplate.spec.template`. `suspend: true` pauses it.
- `ttlSecondsAfterFinished` cleans up finished Jobs. CronJobs clean up through the history limits.
- The `failer` Job ends with condition `Failed=True`, reason **BackoffLimitExceeded**.
