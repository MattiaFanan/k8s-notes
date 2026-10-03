# Job that runs N times with parallelism

**Task:** Create job `batch-job` running `busybox` printing "done", must complete 6 times with 2 running in parallel.

**Fastest route:**
```bash
k create job batch-job --image=busybox $do -- /bin/sh -c 'echo done' > job.yaml
```
Edit `spec` to add:
```yaml
  completions: 6
  parallelism: 2
  backoffLimit: 4
```
```bash
k apply -f job.yaml
```

**Verify:**
```bash
k get job batch-job -w         # COMPLETIONS should climb to 6/6
k get pods -l job-name=batch-job
```

**Gotcha:** don't confuse `completions` (total successful runs needed) with `parallelism` (concurrent pods). A plain `kubectl create job` has no flags for these — must edit YAML.
