# 15 – Helm: release lifecycle (install, upgrade, rollback, template, package)

Run `./setup.sh` first. Namespace: `helm-15`. Work in `exercises/15-helm-chart-lifecycle/work/`.

1. Scaffold a chart: `work/webapp` (`helm create`). Look at `Chart.yaml`, `values.yaml`, `templates/`.
2. Install release `shop` from `work/webapp` in `helm-15` with `replicaCount=2` (`--set`). This is revision 1.
3. Write `work/prod-values.yaml` with `replicaCount: 3` and image tag `1.27-alpine`, and upgrade `shop` with it.
   This is revision 2.
4. A colleague breaks it: upgrade again, **keeping the current values**, with only image tag `does-not-exist`
   (revision 3). Look at the pods.
5. Roll back to revision 2 (this creates revision 4). Check `helm history`.
6. Without installing anything, render the chart with `prod-values.yaml` **and** `replicaCount=4` into `work/rendered.yaml`.
7. Package the chart into `work/` (`webapp-0.1.0.tgz`).
8. Question: what is the name of the Deployment, and where does it come from?

Check with `./verify.sh`, clean up with `./teardown.sh`.
