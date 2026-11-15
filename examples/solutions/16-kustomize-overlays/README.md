# 16 – Solution

The files are in `base/` and `overlays/`, the same layout as the task.

```bash
cd exercises/16-kustomize-overlays/work
kubectl kustomize overlays/dev                # preview, same as: kustomize build overlays/dev
kubectl diff -k overlays/prod                 # what would change in the cluster
kubectl apply -k overlays/dev
kubectl apply -k overlays/prod
kubectl get all,cm -n kust-dev
```
Shortcuts that write the kustomization for you:
`kustomize create --resources deployment.yaml,service.yaml`, `kustomize edit set image nginx:1.27`,
`kustomize edit add configmap web-config --from-literal=APP_ENV=base`.

## Key points
- A **base** is a directory with a `kustomization.yaml`. An **overlay** lists it under `resources:` and adds changes.
  The base is never modified.
- `namespace`, `namePrefix`/`nameSuffix`, `labels`, `images`, `replicas` are built-in transformers. kustomize also updates
  **references**: the Deployment's `configMapRef: web-config` becomes `dev-web-config-<hash>`.
- `labels` with `includeSelectors: true` also changes selectors, so dev and prod pods never match each other's Services.
  Selectors are immutable, so adding this to a running Deployment needs a delete and recreate. The older `commonLabels` field does the same but is deprecated.
- `configMapGenerator` in an overlay with the same name needs `behavior: merge` (or `replace`). Without it you get a
  "already exists" error.
- `-k` takes a **directory**, not a file.

## Answer
The ConfigMap is `dev-web-config-<10-char hash>`. Generators append a hash of the content. When the data changes the name changes,
so the Deployment's pod template changes and a rollout restarts the pods with the new config. A plain ConfigMap edit
would not restart anything. Disable it per generator with `options: {disableNameSuffixHash: true}`.
