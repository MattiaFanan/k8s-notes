# 02 – StorageClass, dynamic provisioning, default class

Run `./setup.sh` first. Namespace: `storage-02`. k3s ships the `rancher.io/local-path` provisioner.

1. Create a StorageClass `local-retain`:
   - provisioner `rancher.io/local-path`
   - reclaim policy `Retain`, volume binding mode `WaitForFirstConsumer`
   - it must **not** be the default class (`local-path` must remain the only default)
2. Create a PVC `web-data` (`64Mi`, `ReadWriteOnce`, class `local-retain`). Check its status. What is it and why?
3. Create a Deployment `web` (1 replica, `nginx:1.27-alpine`) that mounts `web-data` at `/usr/share/nginx/html`.
4. Write `hello from pv` to `/usr/share/nginx/html/index.html` in the running pod.
5. Create a PVC `scratch` (`10Mi`, RWO) **without** `storageClassName`. Which class does it get?
6. Questions (answers in the solution):
   - Why does `scratch` stay `Pending`?
   - What happens to the dynamically created PV when `web-data` is deleted?

Check with `./verify.sh`, clean up with `./teardown.sh`.
