# 17 – Solution

Copy `kustomization.yaml` and `patch-resources.yaml` into `work/`, then:
```bash
kubectl kustomize work | less                 # check the hashed names and the patches
kubectl apply -k work
kubectl rollout status deploy/api -n kust-17
sed -i 's/LOG_LEVEL=info/LOG_LEVEL=warn/' work/kustomization.yaml
kubectl apply -k work                         # new api-config-<hash>, so the pod template changes and a rollout starts
kubectl get cm -n kust-17                     # old and new api-config-* both exist
kubectl rollout history deploy/api -n kust-17
```

## Key points
- **Generators** (`configMapGenerator`, `secretGenerator`): `literals` (KEY=value), `files` (key = file name,
  or `mykey=path` to rename), `envs` (a .env file, one key per line). `type:` on a secret generator makes TLS and other typed secrets.
- **Strategic merge patch**: a partial YAML of the object. Lists such as `containers` are merged by their key (`name`).
  Good for adding or changing fields.
- **JSON 6902 patch**: explicit `op` (`add`, `replace`, `remove`, ...) on a `path`. Precise, and the only way to
  remove fields or edit list items by index (`/spec/template/spec/containers/0/image`). Needs a `target`.
- Both go under `patches:`. The old `patchesStrategicMerge` and `patchesJson6902` fields are deprecated.

## Answers
- The pods restarted because the ConfigMap **name** changed (new content, new hash). kustomize updated every reference
  (envFrom and volume), so the pod template changed and the Deployment did a normal rolling update.
  That is the main reason to keep the hash. With `api-static` (no hash) an edit changes the data but no pod restarts.
- The old `api-config-<oldhash>` is still there: `kubectl apply` does not delete objects that are gone from the output. That makes rollback possible,
  but old objects pile up. Clean up by hand or use `kubectl apply -k work --prune -l <label>` (prune needs a label selector).
