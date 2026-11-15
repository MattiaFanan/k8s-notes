# 03 – Troubleshoot a Pending PVC and Pod

Run `./setup.sh` first. Namespace: `storage-03`.

Setup created a PV `pv-db`, a PVC `pvc-db` and a Pod `db`. The pod is stuck in `Pending`.

Get Pod `db` **Running** with the volume `pv-db` mounted at `/data`.

Rules:
- do **not** modify, delete or recreate the PV `pv-db` (it holds "production data")
- keep the names `pvc-db` and `db`, the pod image and the mount path `/data`
- find every problem with `kubectl describe` / `kubectl get -o yaml`. There is more than one.

Check with `./verify.sh`, clean up with `./teardown.sh`.
