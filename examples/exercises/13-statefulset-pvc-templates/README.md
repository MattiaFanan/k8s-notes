# 13 – volumeClaimTemplates: StatefulSet and generic ephemeral volumes

Run `./setup.sh` first. Namespace: `sts-13`. Use image `busybox:1.36` and class `local-path`.

## Part A – StatefulSet
1. Create a **headless** Service `db` (port 80, selector `app=db`).
2. Create a StatefulSet `db` with 3 replicas that uses Service `db`. Each pod gets its own PVC from a
   `volumeClaimTemplates` entry called `data` (`32Mi`, RWO), mounted at `/data`. The container runs:
   `sh -c 'hostname > /data/hostname; date >> /data/boots; sleep 3600'`
3. The PVCs must be **kept** when the StatefulSet is deleted, and **deleted** when it is scaled down
   (`persistentVolumeClaimRetentionPolicy`).
4. Delete pod `db-1`. When it comes back, `/data/boots` must contain 2 lines: same PVC, data kept.
5. From `db-0`, resolve the stable DNS name of `db-1` with `nslookup`, using the full name `db-1.db.sts-13.svc.cluster.local`
6. Scale the StatefulSet to **2**. What happens to PVC `data-db-2`?

## Part B – generic ephemeral volume
7. Create a Pod `scratch` (`sleep 3600`) with a volume `work` of type `ephemeral` whose `volumeClaimTemplate`
   asks for `16Mi` RWO, mounted at `/scratch`. Find the PVC this creates. What is its name, and who owns it?

Questions (answers in the solution): what are the PVC names and why? How does Part B differ from `emptyDir`?

Check with `./verify.sh`, clean up with `./teardown.sh`.
