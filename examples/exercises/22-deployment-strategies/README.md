# 22 – Deployment strategies: blue/green, canary, rolling update, rollback

Run `./setup.sh` first. Namespace: `deploy-22`. Image for everything: `hashicorp/http-echo:1.0`
(args `-text=<text> -listen=:5678`).

Setup created:
- Deployment `blue` (labels `app=shop,version=blue`, answers `v1`) and Service `shop` (port 80 -> 5678) selecting `app=shop,version=blue`
- Deployment `catalog` (4 replicas, labels `app=catalog,track=stable`, answers `catalog-v1`) and Service `catalog` selecting `app=catalog`

**Blue/green**
1. Create Deployment `green` (2 replicas, labels `app=shop,version=green`, answers `v2`).
2. When green is ready, switch Service `shop` to green in one step. Keep `blue` running (so you can switch back).

**Canary**
3. Create Deployment `catalog-canary` (1 replica, labels `app=catalog,track=canary`, answers `catalog-v2`) so that
   about 20% of the requests to Service `catalog` reach it. Do not change the Service.

**Rolling update + rollback**
4. Set the strategy of `catalog` to RollingUpdate with `maxSurge: 1` and `maxUnavailable: 0`.
5. Update `catalog` so it answers `catalog-v1.1`, and record the change cause `bump to v1.1`.
6. Look at `kubectl rollout history`. Roll back to the revision that answers `catalog-v1`, using `--to-revision`.
7. Question: when would you use `strategy: Recreate`?

Check with `./verify.sh`, clean up with `./teardown.sh`.
