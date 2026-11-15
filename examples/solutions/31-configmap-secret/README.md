# 31 – Solution

```bash
kubectl create cm app-config -n config-31 --from-literal=APP_MODE=prod --from-literal=APP_COLOR=blue --from-file=work/app.properties
kubectl create secret generic db-creds -n config-31 --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cr3t
kubectl apply -f app.yaml
# step 4: regenerate and apply (or kubectl edit cm app-config)
kubectl create cm app-config -n config-31 --from-literal=APP_MODE=staging --from-literal=APP_COLOR=blue \
  --from-file=work/app.properties --dry-run=client -o yaml | kubectl apply -f -
kubectl exec -n config-31 app -- cat /etc/config/app.properties   # debug after ~1 min
kubectl exec -n config-31 app -- sh -c 'echo $MODE'               # still prod
# step 5
kubectl create cm frozen -n config-31 --from-literal=VERSION=1 --dry-run=client -o yaml > frozen.yaml
#   add a top-level line "immutable: true", then apply
kubectl apply -f frozen.yaml
# step 6
kubectl get secret db-creds -n config-31 -o jsonpath='{.data.DB_PASSWORD}' | base64 -d > work/password.txt
```

## Key points
- `--from-file=path` uses the file name as key (`--from-file=key=path` to rename); `--from-env-file` turns each line into a key.
- **Env vars are read once**, when the container starts. Changing the ConfigMap changes nothing until the pod is recreated
  (`kubectl rollout restart` for a Deployment, or a hash in the name like kustomize's generators, see 17).
- **Mounted volumes are updated** by the kubelet (sync period + cache, usually < 1 min). The app must re-read the file.
- `optional: true` lets the pod start when the ConfigMap/key is missing. Without it: `CreateContainerConfigError`.
- `items:` picks keys and file names. Without it every key becomes a file (so `APP_MODE`, `APP_COLOR` too).
- Secrets are only **base64**, not encrypted. `data` is base64, `stringData` lets you write plain text in YAML.
  Protection = RBAC on `secrets` + encryption at rest in etcd.
- `immutable: true` (ConfigMap and Secret): no updates to `data`, only delete + recreate. The kubelet stops watching it (less load).
- Other secret types: `kubectl create secret tls` (06), `docker-registry` (`imagePullSecrets`).

## Answer
7: No. A `subPath` mount is a copy made at container start and is **never** updated. Same for env vars.
