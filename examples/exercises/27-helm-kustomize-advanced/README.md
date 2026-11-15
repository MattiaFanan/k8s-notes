# 27 – Helm dependencies + kustomize on top of Helm

Run `./setup.sh` first. Namespaces: `helm-27`, `helm-27-kust`. Work in `exercises/27-helm-kustomize-advanced/work/`.

**Umbrella chart with a subchart**
1. `helm create work/backend` and `helm create work/platform`.
2. Make `backend` a **dependency** of `platform` (local path `file://../backend`, version `0.1.0`) that can be switched off
   with the value `backend.enabled`.
3. In `platform`'s own `values.yaml`, override the **subchart's** values: `replicaCount: 2`, image tag `1.27-alpine`
   (and `enabled: true`).
4. Fetch the dependency into `platform/charts/` and install release `plat` from `work/platform` in `helm-27`.
   Expected: Deployments `plat-platform` (1 replica) and `plat-backend` (2 replicas, `nginx:1.27-alpine`).
5. Show that `--set backend.enabled=false` removes `plat-backend` from the rendered output.

**kustomize on top of helm output** (a "last-mile" change the chart does not support)
6. Render the chart **without tests** into `work/kust/rendered.yaml` (release name `plat`).
7. Write `work/kust/kustomization.yaml` that takes `rendered.yaml` and:
   - puts everything in namespace `helm-27-kust`
   - adds label `rendered-by=kustomize` to all objects (not to selectors)
   - sets `plat-platform` to 3 replicas
   Apply it with `kubectl apply -k`. This is plain kubectl: no Helm release in `helm-27-kust`.

Check with `./verify.sh`, clean up with `./teardown.sh`.
