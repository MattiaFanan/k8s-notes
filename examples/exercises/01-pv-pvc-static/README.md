# 01 – Static PersistentVolume + PVC with a label selector

Run `./setup.sh` first. Namespace: `storage-01`.

1. Create a PersistentVolume `pv-logs`:
   - capacity `200Mi`, access mode `ReadWriteOnce`, reclaim policy `Retain`
   - `storageClassName: manual`, label `tier=logs`
   - `hostPath` `/tmp/ckad/pv-logs` (type `DirectoryOrCreate`)
2. Create a PVC `pvc-logs` in `storage-01` requesting `100Mi`, `ReadWriteOnce`, class `manual`,
   that may **only** bind to volumes labelled `tier=logs` (use `selector.matchLabels`).
3. Create a Pod `logger` (image `busybox:1.36`) in `storage-01` that mounts `pvc-logs` at `/var/log/app`
   and appends the output of `date` to `/var/log/app/out.log` every 5 seconds.
4. Questions (answers in the solution):
   - What capacity does `kubectl get pvc pvc-logs` report, 100Mi or 200Mi? Why?
   - What happens to `pv-logs` when you delete the PVC?

Check with `./verify.sh`, clean up with `./teardown.sh`.
