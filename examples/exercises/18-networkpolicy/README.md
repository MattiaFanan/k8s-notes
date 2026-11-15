# 18 – NetworkPolicy: default deny, then allow exactly what is needed

Run `./setup.sh` first. k3s enforces NetworkPolicies (embedded kube-router).

Namespace `np-18`:

| pod / deployment | labels | listens |
|------------------|--------|---------|
| deploy `web` (svc `web:80`) | `app=web` | 5678 |
| deploy `api` (svc `api:80`) | `app=api` | 5678 |
| deploy `db`  (svc `db:80`)  | `app=db`  | 5678 |
| pod `frontend` (busybox) | `role=frontend` | - |
| pod `intruder` (busybox) | `role=other` | - |

Namespace `np-18-monitor` (label `team=monitoring`) has pod `prober` (`app=prober`).
Namespace `np-18-other` (no labels) has pod `prober` (`app=prober`) too.

Today everything can talk to everything. Create these NetworkPolicies in `np-18`:

1. `default-deny`: deny **all ingress and all egress** for every pod in `np-18`.
2. `allow-dns`: allow every pod in `np-18` egress to CoreDNS (`kube-system`, pods `k8s-app=kube-dns`) on UDP and TCP 53.
3. `web-ingress`: `web` accepts traffic only from `role=frontend` pods.
4. `api-ingress`: `api` accepts traffic from `role=frontend` pods, **and** from pods labelled `app=prober` that are in a
   namespace labelled `team=monitoring` (only the prober in `np-18-monitor`, not the one in `np-18-other`).
5. `db-ingress`: `db` accepts traffic only from `app=api` pods.
6. `frontend-egress`: `frontend` may connect out to `web` and `api` pods (and nothing else, apart from DNS).
7. `api-egress`: `api` may connect out to `db` pods.

Expected (test with `kubectl exec -n np-18 frontend -- wget -qO- -T 3 http://web`):

| from | web | api | db |
|------|-----|-----|----|
| np-18/frontend | ok | ok | blocked |
| np-18/intruder | blocked | blocked | blocked |
| np-18-monitor/prober | blocked | ok | blocked |
| np-18-other/prober | blocked | blocked | blocked |

Hint: think about which **port** a policy sees: the Service port (80) or the pod port (5678)?

Check with `./verify.sh`, clean up with `./teardown.sh`.
