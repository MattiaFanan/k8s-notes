# CronJob running on a schedule

**Task:** Create a CronJob `hello-cron` running every 5 minutes, image `busybox`, printing the date, keep only 2 successful and 1 failed job in history.

**Fastest route:**
```bash
k create cronjob hello-cron --image=busybox --schedule="*/5 * * * *" $do \
  -- /bin/sh -c 'date; echo hello' > cj.yaml
```
Edit `spec`:
```yaml
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
```
```bash
k apply -f cj.yaml
```

**Verify:**
```bash
k get cronjob hello-cron
k create job --from=cronjob/hello-cron test-run   # manually trigger, don't wait 5 min
k get jobs
```

**Gotcha:** to test a cronjob without waiting for the schedule, always use `k create job --from=cronjob/<name> <manual-name>` — huge time saver on the exam.
