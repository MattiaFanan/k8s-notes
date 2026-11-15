# 32 – Solution

```bash
kubectl apply -f quotas.yaml            # everything except ratio (step 10 is applied last: ratio.yaml)
# A
kubectl get deploy,rs -n dev-32
kubectl describe rs -n dev-32 | grep -A3 Events
#   failed quota: compute: must specify limits.cpu for: nginx
kubectl rollout restart deploy/web -n dev-32      # only if the RS is still backing off
kubectl scale deploy web -n dev-32 --replicas=4
kubectl describe quota compute -n dev-32
#   limits.cpu 600m/600m  requests.cpu 300m/500m   → limits.cpu blocks (4th pod would need 800m)
# B
kubectl describe quota storage -n storage-32; kubectl describe limits pvc-limits -n storage-32
#   tiny   → LimitRange: minimum storage usage per PersistentVolumeClaim is 100Mi
#   data-2 → quota: exceeded quota: storage, requested: local-path...requests.storage=300Mi, used: 300Mi, limited: 500Mi
# C
kubectl create quota objects -n batch-32 --hard=configmaps=2,services=1,services.nodeports=0
kubectl get cm -n batch-32               # kube-root-ca.crt is already there → 1/2 used
kubectl apply -f ratio.yaml
kubectl run greedy ...                   # cpu max limit to request ratio per Container is 2, but provided ratio is 4
kubectl run be-3 ...                     # also rejected: no request is specified
```

## Key points
- A quota on `limits.X`/`requests.X` makes that field **mandatory** in every new pod. A LimitRange default fills it in,
  which is the usual fix when you may not change the workload.
- Quota errors show up on the **ReplicaSet** (events), not on the Deployment and not on `kubectl scale`.
- Quotas count at admission, after mutating plugins: the DefaultStorageClass plugin sets `storageClassName: local-path`
  on `data-2` first, so the per-class quota applies. A Pending PVC (WaitForFirstConsumer) still counts.
- LimitRange types: `Container` (default, defaultRequest, min, max, maxLimitRequestRatio), `Pod` (min/max of the sum),
  `PersistentVolumeClaim` (min/max storage).
- Scopes: `BestEffort` / `NotBestEffort`, `Terminating` / `NotTerminating` (activeDeadlineSeconds), `PriorityClass`
  (with `scopeSelector`). A scoped quota only counts pods that match it, so `burst` is not counted by `besteffort`.
  A BestEffort-scoped quota may only limit `pods`.
- Object counts: short names (`configmaps`, `secrets`, `services`, `services.nodeports`, `services.loadbalancers`,
  `persistentvolumeclaims`) or the generic `count/<resource>.<group>` (`count/deployments.apps`, `count/jobs.batch`).
- `maxLimitRequestRatio` needs **both** request and limit on every container: with `ratio` in place, BestEffort pods
  (`be-1`) and request-only pods (`burst`) are rejected too. That's why step 10 comes last. Add `default`/`defaultRequest`
  to the same LimitRange if pods without resources must still work.
- Every namespace gets ConfigMap `kube-root-ca.crt` automatically, so it uses one ConfigMap slot.
- `kubectl describe ns <ns>` shows all quotas and LimitRanges of a namespace in one place.

## Answer
11: Nothing happens to them. Quotas and LimitRanges are only checked when objects are **created/updated**.
`describe quota` shows `pods 3/1`, and no new pod can be created until usage is below the limit.
