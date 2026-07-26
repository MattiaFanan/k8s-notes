# Deployments & Workloads - YAML Structure

Deployments manage ReplicaSets to ensure a desired number of pod replicas are running at any time, enabling rolling updates and rollbacks. Jobs run pods to completion, executing tasks that must finish successfully a specified number of times. CronJobs schedule Jobs to run periodically at specified times, similar to cron on a Unix system. Together, these workload resources cover the spectrum of one-off, scheduled, and long-running workloads in Kubernetes.

## Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deploy
spec:
  replicas: 3
  strategy:
    type: RollingUpdate         # RollingUpdate | Recreate
    rollingUpdate:
      maxSurge: 25%             # Max pods above desired replicas
      maxUnavailable: 25%       # Max unavailable pods during rollout
  selector:
    matchLabels:
      app: web                  # MUST match spec.template.metadata.labels
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

## Job Manifest

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-job
spec:
  completions: 3               # Total successful runs needed
  parallelism: 1               # Number of pods running in parallel
  backoffLimit: 4              # Retries before marking job failed
  activeDeadlineSeconds: 100   # Max job duration in seconds
  template:
    spec:
      restartPolicy: OnFailure # MUST be OnFailure or Never
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-we", "print bpi(2000)"]
```

## CronJob Manifest

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cron-log
spec:
  schedule: "*/5 * * * *"        # Cron syntax: Min Hr Day Month DayOfWeek
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Allow       # Allow | Forbid | Replace
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "date"]
```

## Field Reference

| Field | Required / Optional / Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| `apiVersion` | Important | **No** (requires `kubectl replace`) | Defines the API group and version (e.g. `apps/v1`). Immutable once the resource is created. Must match the schema expected by the API server. |
| `kind` | Important | **No** (requires `kubectl replace`) | Identifies the resource type (e.g. `Deployment`, `Job`, `CronJob`). Immutable. |
| `metadata.name` | Important | **No** (requires `kubectl replace`) | Name of the resource, unique within the namespace. Immutable. Changing it requires recreating the resource. |
| `metadata.labels` / `metadata.annotations` | Optional | **Yes** | Labels are used for selectors and querying; annotations store arbitrary metadata. Changes apply immediately with no rollout. |
| `spec.replicas` | Optional | **Yes** (no rollout) | Desired number of pod replicas. Changing it scales the Deployment immediately but does **not** trigger a pod rollout. |
| `spec.strategy.type` | Optional | **Yes** (no rollout) | `RollingUpdate` (default) or `Recreate`. Changing strategy mid-rollout can cause unexpected behaviour; set before deploying. |
| `spec.strategy.rollingUpdate.maxSurge` | Optional | **Yes** (no rollout) | Max pods above desired count during an update (absolute number or percentage). Tune to control rollout speed. |
| `spec.strategy.rollingUpdate.maxUnavailable` | Optional | **Yes** (no rollout) | Max pods unavailable during an update (absolute number or percentage). Lower values mean slower but safer rollouts. |
| `spec.selector` | Required | **No** (requires `kubectl replace`) | Match labels for the pods this Deployment manages. **Immutable** after creation — must align with `spec.template.metadata.labels`. |
| `spec.template` (any sub-field) | Required | **Yes** (triggers rollout) | The pod template. **Any change** to this block (labels, container images, ports, env vars, volumes, etc.) triggers a new rollout. |
| `spec.template.metadata.labels` | Required | **Yes** (triggers rollout if changed) | Must include all labels referenced in `spec.selector.matchLabels`. Altering these triggers a rollout; ensure selector still matches after changes. |
| `spec.template.spec.containers[*].image` | Required | **Yes** (triggers rollout) | Container image tag or digest. Changing the image is the most common rollout trigger. Use explicit tags or digests for reproducibility; avoid `latest` in production. |
| `spec.template.spec.containers[*].ports` | Optional | **Yes** (triggers rollout if changed) | Container port declarations. Changing ports triggers a rollout. Ensure the container actually listens on the declared port. |
| `spec.template.spec.containers[*].env` | Optional | **Yes** (triggers rollout if changed) | Environment variables passed to the container. Modifying env triggers a rollout. Use ConfigMaps/Secrets for large or sensitive values. |
| `spec.template.spec.containers[*].resources` | Optional | **Yes** (triggers rollout if changed) | CPU/memory requests and limits. Changing resource quotas triggers a rollout. Set requests for scheduling and limits to prevent resource exhaustion. |
| `spec.template.spec.restartPolicy` | Optional (Job/CronJob) | **No** (immutable for Job) | For Jobs must be `OnFailure` or `Never`. Once set on a Job template it is immutable — cannot be changed via `kubectl edit`. |
| `spec.completions` | Optional (Job) | **Yes** | Total number of successful completions required (default 1). Changing it affects the Job's target but does not restart in-flight pods. |
| `spec.parallelism` | Optional (Job/CronJob) | **Yes** | Number of pods running in parallel. Adjusting scales active pods immediately. |
| `spec.backoffLimit` | Optional (Job) | **Yes** | Number of retries before marking the Job as failed (default 6). Change before running; has no effect on already-failed pods. |
| `spec.activeDeadlineSeconds` | Optional (Job) | **Yes** | Maximum duration (seconds) of the Job before it is terminated. Changing it applies to pods created after the change. |
| `spec.schedule` | Required (CronJob) | **Yes** | Cron expression for the job schedule. Modifying it takes effect at the next scheduled run. |
| `spec.successfulJobsHistoryLimit` | Optional (CronJob) | **Yes** | Number of completed jobs to retain (default 3). Lower values reduce etcd storage usage; set to 0 to disable retention. |
| `spec.failedJobsHistoryLimit` | Optional (CronJob) | **Yes** | Number of failed jobs to retain (default 1). Higher values help with debugging failed runs. |
| `spec.concurrencyPolicy` | Optional (CronJob) | **Yes** | `Allow` (default), `Forbid`, or `Replace`. Controls how overlapping CronJob runs are handled. `Forbid` prevents concurrent runs; `Replace` cancels the previous run. |
