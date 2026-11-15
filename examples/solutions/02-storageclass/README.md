# 02 – Solution

```bash
kubectl apply -f storageclass.yaml -f pvc.yaml
kubectl get pvc -n storage-02            # both Pending
kubectl describe pvc web-data -n storage-02   # "waiting for first consumer to be created before binding"
kubectl apply -f deployment.yaml
kubectl exec -n storage-02 deploy/web -- sh -c 'echo "hello from pv" > /usr/share/nginx/html/index.html'
kubectl get pvc,pv
```

Imperative shortcut for the Deployment: `kubectl create deploy web --image=nginx:1.27-alpine -n storage-02 --dry-run=client -o yaml > d.yaml`,
then add `volumes` and `volumeMounts`.

## Key points
- A **StorageClass** is cluster-scoped. Its fields (`provisioner`, `reclaimPolicy`, `volumeBindingMode`, `parameters`)
  are **immutable**: to change them, delete the class and create it again.
- **Default class**: the annotation `storageclass.kubernetes.io/is-default-class: "true"`. Leave it out and the class is not default.
  To switch the default: `kubectl patch sc <name> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`
  (and set it to `"false"` on the old one).
- `reclaimPolicy` of the class is copied to every PV it provisions (the default is `Delete`).

## Answers
- `web-data` was **Pending** until the Deployment's pod existed. That is `WaitForFirstConsumer`: the PV is created
  only after the scheduler picks a node for a pod that uses the claim, so the volume is created on that node.
  `Immediate` would provision right away.
- `scratch` got `storageClassName: local-path` (the default class, set by admission when the claim is created). It stays Pending because
  `local-path` is also WaitForFirstConsumer and no pod uses it.
- Deleting `web-data` leaves the PV in **Released** with its data, because the class says `Retain`. With `local-path` (`Delete`) the PV
  and the directory on the node would be removed.
