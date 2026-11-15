# 17 – Kustomize: generators, patches, config-triggered rollouts

Run `./setup.sh` first. It creates namespace `kust-17` and, in `exercises/17-kustomize-generators-patches/work/`,
a `deployment.yaml` (Deployment `api`, which uses ConfigMap `api-config` and Secret `api-secret`) and a `settings.json`.
Do **not** edit `deployment.yaml`. Write `work/kustomization.yaml` (and any patch files) so that:

1. Everything goes to namespace `kust-17`.
2. ConfigMap `api-config` is generated from the literal `LOG_LEVEL=info` and the file `settings.json`.
3. Secret `api-secret` is generated from the literal `DB_PASSWORD=changeme`.
4. ConfigMap `api-static` (`OWNER=team-a`) is generated **without** the hash suffix: its name is exactly `api-static`.
5. A **strategic merge patch** file `patch-resources.yaml` gives container `api` requests `cpu: 50m`, `memory: 32Mi`
   and limit `memory: 64Mi`.
6. An **inline JSON 6902 patch** sets `/spec/replicas` to `2`.
7. `kubectl apply -k work`. Wait for the rollout.
8. Change `LOG_LEVEL` to `warn` and apply again. Watch what happens to the pods and the ConfigMaps.

Questions (answers in the solution): why did the pods restart in step 8? What happened to the old ConfigMap?

Check with `./verify.sh` (after step 8), clean up with `./teardown.sh`.
