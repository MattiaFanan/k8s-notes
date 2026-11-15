# 01 – Solution

```bash
kubectl apply -f pv.yaml -f pvc.yaml -f pod.yaml
kubectl get pv,pvc -n storage-01
```

There is no imperative `kubectl create pv/pvc`, so write YAML (copy a skeleton from the docs page
"Configure a Pod to Use a PersistentVolume for Storage").

## Why it works
- **PV** is cluster-scoped (no namespace). **PVC** is namespaced. The binder pairs them when
  `storageClassName`, `accessModes`, size (PV >= request) and `selector` all match.
- `storageClassName: manual` matters on **both** sides. If you leave it out of the PVC, the
  DefaultStorageClass admission plugin fills in `local-path`, and the claim gets a new dynamic volume instead of `pv-logs`.
  (To ask for "no class at all", set `storageClassName: ""`.)
- `selector.matchLabels` restricts the candidate PVs. A claim with a selector is never dynamically provisioned.
- The pod refers to the **claim**, never to the PV.

## Answers
- The PVC shows **200Mi**. A PV binds as a whole, so the claim gets the full PV capacity,
  even though it asked for only 100Mi.
- Deleting the PVC with `Retain` moves the PV to **Released**. The data stays, but the PV is *not* reusable
  until you delete it or remove `spec.claimRef` (`kubectl patch pv pv-logs --type json -p '[{"op":"remove","path":"/spec/claimRef"}]'`).
  With `Delete` the volume itself would be removed (dynamic provisioners only).
