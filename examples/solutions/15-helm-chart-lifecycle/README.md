# 15 – Solution

```bash
cd exercises/15-helm-chart-lifecycle/work
helm create webapp                                              # 1
helm install shop ./webapp -n helm-15 --set replicaCount=2      # 2  rev 1
helm upgrade shop ./webapp -n helm-15 -f prod-values.yaml       # 3  rev 2
helm upgrade shop ./webapp -n helm-15 --reuse-values --set image.tag=does-not-exist   # 4  rev 3
kubectl get pods -n helm-15                                     #    ImagePullBackOff on the new pods
helm history shop -n helm-15
helm rollback shop 2 -n helm-15                                 # 5  rev 4 = copy of rev 2
helm template shop ./webapp -f prod-values.yaml --set replicaCount=4 > rendered.yaml  # 6
helm package ./webapp -d .                                      # 7  webapp-0.1.0.tgz (version from Chart.yaml)
```

## Key points
- `helm upgrade` **without** `-f`/`--set` resets to the chart defaults. `--reuse-values` keeps the previous values and
  adds your new `--set` on top (`--reset-then-reuse-values` also picks up new chart defaults).
  Without it, step 4 would have dropped back to 1 replica and the default tag.
- `helm rollback <release> <revision>` never rewrites history. It creates a **new** revision with the old manifest.
  `helm history` shows `Rollback to 2` as its description.
- `helm get values shop --revision N` / `helm get manifest shop` show what was applied in a revision.
- `helm template` renders locally and talks to no cluster. `helm install --dry-run=server` renders and validates against the cluster.
  `helm lint ./webapp` checks the chart.
- `helm upgrade --install` is the idempotent "install or upgrade" used in pipelines.

## Answer
The Deployment is `shop-webapp`. The `helm create` templates name objects with the `webapp.fullname` helper in
`templates/_helpers.tpl`: `<release name>-<chart name>`, or just the release name if it already contains the chart name.
Image: `{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}`, so without a tag you get the chart's `appVersion`.
