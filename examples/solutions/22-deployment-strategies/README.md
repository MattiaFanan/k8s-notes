# 22 – Solution

```bash
kubectl apply -f green.yaml                    # green + catalog-canary
kubectl rollout status deploy/green -n deploy-22
# blue/green switch: one atomic change of the selector
kubectl patch svc shop -n deploy-22 -p '{"spec":{"selector":{"app":"shop","version":"green"}}}'
kubectl get endpointslices -n deploy-22 -l kubernetes.io/service-name=shop
# switching back = the same patch with version: blue

# rolling update settings
kubectl patch deploy catalog -n deploy-22 -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
kubectl edit deploy catalog -n deploy-22       # change args to -text=catalog-v1.1 (or a JSON patch, see solve.sh)
kubectl annotate deploy catalog -n deploy-22 kubernetes.io/change-cause="bump to v1.1"
kubectl rollout history deploy/catalog -n deploy-22
kubectl rollout history deploy/catalog -n deploy-22 --revision=1     # show what revision 1 contains
kubectl rollout undo deploy/catalog -n deploy-22 --to-revision=1
```
Test traffic from inside the cluster:
`kubectl run t -n deploy-22 --rm -it --image=busybox:1.36 -- sh -c 'for i in $(seq 20); do wget -qO- catalog; done'`.

## Key points
- **Blue/green**: two full Deployments, the Service selector decides who gets the traffic. The switch is immediate and so is the rollback.
  The cost is double the resources while both run.
- **Canary with plain Kubernetes**: the Service load-balances over all matching pods, so the traffic share equals the **pod ratio**
  (1 of 5 = 20%). For exact percentages you need an Ingress controller, a Gateway API weight (exercise 29) or a service mesh.
- The canary must share the **Service's** label (`app=catalog`) but needs its own Deployment selector (`track=canary`), so the two
  Deployments don't fight over pods.
- `maxSurge` = extra pods allowed above `replicas`, `maxUnavailable` = pods that may be missing. `1/0` means capacity never drops.
- Revisions come from ReplicaSets (`revisionHistoryLimit`, default 10). An undo **moves** the old revision to a new number
  (revision 1 becomes 3). `CHANGE-CAUSE` is read from the annotation `kubernetes.io/change-cause` (the old `--record` flag is gone).
- `kubectl set image deploy/x c=img:tag` and `kubectl rollout pause/resume/restart` are worth knowing too.

## Answer
`Recreate` kills all old pods before it starts new ones, which means downtime. Use it when two versions must never run at the same time: a schema migration,
a single-writer app, or a RWO volume that only one pod can mount.
