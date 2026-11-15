# 26 – API deprecations: fix old manifests

Run `./setup.sh` first. Namespace: `api-26`. Setup writes old manifests to `work/old/` (from a blog post written in 2019).
None of them can be applied to this cluster.

1. Try `kubectl apply -f work/old/`. Read the errors.
2. For each resource kind, find the API version this cluster serves (`kubectl api-resources`, `kubectl explain <kind>`).
3. Write fixed copies to `work/new/` and apply them to `api-26`. Keep names, labels and behaviour:
   - Deployment `web` (nginx, 2 replicas)
   - Service `web`
   - Ingress `web` (host `web.ckad.local`, `/` -> `web:80`, traefik class)
   - CronJob `nightly`
   - PodDisruptionBudget `web` (minAvailable 1)
   - HorizontalPodAutoscaler `web` (1 to 3 replicas, 50% CPU)
4. Besides the version, some resources need **field changes**. Which ones, and what changed?

Check with `./verify.sh`, clean up with `./teardown.sh`.
