# 25 – CustomResourceDefinitions and custom resources

Run `./setup.sh` first. Namespace: `crd-25`.

1. Create a CRD for kind `Backup`:
   - group `ckad.example.com`, version `v1` (served + storage), plural `backups`, singular `backup`, short name `bk`, **namespaced**
   - schema: `spec.schedule` (string, **required**), `spec.retention` (integer, 1 to 30), `spec.target` (string)
   - `kubectl get bk` shows extra columns `Schedule` (`.spec.schedule`) and `Retention` (`.spec.retention`)
2. Create Backup `nightly` in `crd-25`: schedule `0 2 * * *`, retention `7`, target `db`.
3. Try a Backup with `retention: 100`, and one without `schedule`. Both must be rejected.
4. Use `kubectl explain backup.spec` and `kubectl api-resources --api-group=ckad.example.com`.
5. Create a ServiceAccount `backup-operator` and a Role `backup-editor` in `crd-25` that allow **all** verbs on backups
   (and nothing else). Bind them.
6. Question: what makes a CRD an "operator"?

Check with `./verify.sh`, clean up with `./teardown.sh`.
