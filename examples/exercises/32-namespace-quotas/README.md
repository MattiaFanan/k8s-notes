# 32 – Namespace quotas and limits, harder (builds on 20)

Run `./setup.sh` first. Namespaces: `dev-32`, `storage-32`, `batch-32`. Write answers in `work/`.

## A. dev-32: a Deployment that never starts
Setup created ResourceQuota `compute` and Deployment `web` (2 replicas, cpu request only).
1. `web` is `0/2`. Find the reason (where do you look when a Deployment has no pods?).
   Fix it **without editing the Deployment or the quota**: LimitRange `dev-defaults` that gives containers a default
   cpu **limit** of `200m`. (If no pods show up after a minute, `kubectl rollout restart` is allowed – the RS backs off.)
2. Scale `web` to `4`. How many pods run? Which line of the quota stops it? Write just the resource name
   (e.g. `pods`) to `work/blocking.txt`.

## B. storage-32: storage quota
3. ResourceQuota `storage`: max `2` PVCs, `1Gi` requested storage in total, and at most `500Mi` on StorageClass `local-path`.
4. LimitRange `pvc-limits`: every PVC between `100Mi` and `400Mi`.
5. Create PVC `data-1` (`300Mi`, RWO). Then try PVC `tiny` (`50Mi`) and PVC `data-2` (`300Mi`).
   Which object rejects each one? (`data-2` doesn't set a class – why does the `local-path` limit still apply?)

## C. batch-32: scopes, object counts, ratios
6. ResourceQuota `besteffort` that allows only `1` **BestEffort** pod (use `scopes`).
   ResourceQuota `objects`: max `2` ConfigMaps, `1` Service, `0` NodePort Services.
7. Pods `be-1` and `be-2` (`busybox:1.36`, `sleep 3600`, no resources). Then pod `burst` with requests
   `cpu: 50m`, `memory: 32Mi` and no limits. Which ones are created, and why?
8. Create ConfigMaps `cm-1` and `cm-2` (any data). Only one works – why? Write the name of the object that uses the
   other slot to `work/why-cm.txt`.
9. Service `svc-np` (NodePort, port 80, selector `app=x`) → should fail. Service `svc-a` (ClusterIP, port 80) → works.
10. (do this **after** 7) LimitRange `ratio`: a container's cpu limit may be at most **2×** its request. Show that a pod
    `greedy` with request `50m` / limit `200m` is rejected. Now try another pod like `be-1` (`be-3`). Why does it fail?
11. Question: you add a quota `pods: "1"` to a namespace that already runs 3 pods. What happens to them?

Check with `./verify.sh`, clean up with `./teardown.sh`.
