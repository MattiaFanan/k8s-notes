# 23 – Jobs and CronJobs

Run `./setup.sh` first. Namespace: `jobs-23`. Image for everything: `busybox:1.36`.

1. Job `batch`: runs `sh -c 'echo processed by $HOSTNAME; sleep 2'`, must succeed **6** times, at most **2** pods
   in parallel, at most 2 retries, give up after **120s**, and delete itself **10 minutes** after it finishes.
2. Job `indexed`: 3 completions in **Indexed** mode. Each pod prints `index=<its completion index>`.
3. Job `failer`: runs `sh -c 'exit 1'`, at most **1** retry. After it gives up, which condition and reason does it have?
4. CronJob `reporter`:
   - every 5 minutes, time zone `Etc/UTC`, runs `sh -c 'date; echo report done'`
   - never runs two at the same time
   - keeps 2 successful and 1 failed Job
   - skips a run that could not start within 60s of its schedule
5. Don't wait 5 minutes: start a Job `reporter-manual` from the CronJob now.

Check with `./verify.sh`, clean up with `./teardown.sh`.
