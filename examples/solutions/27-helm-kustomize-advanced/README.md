# 27 – Solution

```bash
cd exercises/27-helm-kustomize-advanced/work
helm create backend && helm create platform
cat >> platform/Chart.yaml < ../../../solutions/27-helm-kustomize-advanced/Chart-dependencies.yaml
cat >> platform/values.yaml < ../../../solutions/27-helm-kustomize-advanced/values-backend.yaml
helm dependency update platform          # copies backend into platform/charts/backend-0.1.0.tgz (+ Chart.lock)
helm dependency list platform            # STATUS ok
helm install plat ./platform -n helm-27
helm template plat ./platform --set backend.enabled=false | grep 'name: plat-'   # no plat-backend

helm template plat ./platform --skip-tests > kust/rendered.yaml
cp ../../../solutions/27-helm-kustomize-advanced/kustomization.yaml kust/
kubectl apply -k kust
```

## Key points
- **Dependencies** are listed in `Chart.yaml` and downloaded into `charts/` by `helm dependency update` (`build` uses the
  existing `Chart.lock`). Without that step, install fails with "found in Chart.yaml, but missing in charts/ directory".
- **Values for a subchart** go under a key with the subchart's name (or its `alias`) in the parent's values, or on the command line:
  `--set backend.replicaCount=2`. Values under `global:` are shared with all subcharts.
- `condition:` points to a parent value that switches the subchart. `tags:` switch groups of subcharts.
- Subchart objects use the release name too: `plat-backend`.
- **helm template + kustomize** is the usual way to make changes a chart has no value for (extra labels, patches, namespace).
  The result is not a Helm release: `helm list` doesn't show it and `helm rollback` doesn't work. kustomize can also call helm
  itself (`helmCharts:` in kustomization.yaml, with `kustomize build --enable-helm`). Helm 4 also has post-renderer plugins.
- `--skip-tests` leaves out the `templates/tests/` hook pods. Without it they would be applied as normal pods.
