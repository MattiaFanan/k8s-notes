# CKAD practice – storage, ingress, service accounts, kubeconfig, RBAC (k3s)

Every exercise lives in `exercises/<name>/`:

| file | what |
|------|------|
| `README.md`   | the task |
| `setup.sh`    | prepares the cluster (run first) |
| `verify.sh`   | checks your work, prints PASS/FAIL per item |
| `teardown.sh` | removes everything the exercise created |

The explained solution is in `solutions/<name>/` (`README.md` + manifests, `solve.sh` applies it).

All scripts use `KUBECONFIG=~/.kube/k3s.yaml` (see `lib.sh`) and never modify it.
Exercises that need their own kubeconfig create a **new** file in `exercises/<name>/work/`.
While solving, use the same cluster:

```bash
export KUBECONFIG=~/.kube/k3s.yaml
alias k=kubectl
```

| # | topic | exercise |
|---|-------|----------|
| 01 | PV / PVC | static PV + PVC with label selector |
| 02 | StorageClass | custom class, WaitForFirstConsumer, default class |
| 03 | PV / PVC | troubleshoot a Pending PVC and Pod |
| 04 | Ingress | fan-out by host and path, Exact vs Prefix |
| 05 | IngressClass | custom class, default class, legacy annotation |
| 06 | Ingress | troubleshoot backend + add TLS |
| 07 | ServiceAccount | automount, projected tokens, token secrets |
| 08 | ServiceAccount + RBAC | SA calling the API from a pod |
| 09 | Users | create a user with a CSR + its own kubeconfig |
| 10 | Clusters / contexts | kubeconfig surgery on a separate file |
| 11 | RBAC | ClusterRole, groups, resourceNames |
| 12 | RBAC | troubleshoot a broken Role/RoleBinding |
| 13 | volumeClaimTemplates | StatefulSet per-pod PVCs, retention policy, generic ephemeral volume |
| 14 | Helm + IngressClass | install ingress-nginx with helm, default class, curl test |
| 15 | Helm | install / upgrade / reuse-values / rollback / template / package |
| 16 | Kustomize | base + dev/prod overlays, configMapGenerator, prefix, labels, images, replicas |
| 17 | Kustomize | generators, strategic merge + JSON 6902 patches, hash-triggered rollouts |
| 18 | NetworkPolicy | default deny, DNS egress, pod/namespace selectors (AND vs OR), pod ports |
| 19 | Pod security | securityContext (non-root, drop ALL, read-only root fs, fsGroup), Pod Security Admission labels |
| 20 | ResourceQuota / LimitRange | defaults, max, quota stopping a scale-up |
| 21 | Probes / debugging | readiness/liveness/startup, `logs --previous`, ephemeral debug containers |
| 22 | Deployment strategies | blue/green, canary by pod ratio, maxSurge/maxUnavailable, rollout undo |
| 23 | Jobs / CronJobs | completions, parallelism, Indexed, backoffLimit, CronJob policies, `create job --from` |
| 24 | Multi-container pods | init containers, native sidecars, sidecar in a Job |
| 25 | CRDs | CRD with schema validation + printer columns, custom resources, RBAC for them |
| 26 | API deprecations | migrate old manifests to current API versions |
| 27 | Helm + Kustomize advanced | subchart dependency + values override, kustomize on helm template output |
| 28 | Ingress annotations | ingress-nginx rewrite-target, basic auth, canary by header |
| 29 | Gateway API | GatewayClass, Gateway, HTTPRoute (header match, weights, filters), allowedRoutes |
| 30 | HPA | `kubectl autoscale`, missing requests, autoscaling/v2 behavior, load test, HPA vs manual scale |
| 31 | ConfigMap / Secret | create from literal/file, env/envFrom, optional keys, volume items + mode, live update vs env, immutable |
| 32 | Quotas / LimitRange (harder) | LimitRange as quota fix, storage + per-class quota, PVC limits, scopes, object counts, limit/request ratio |

Ingress checks curl traefik on `127.0.0.1:80/443` with a `Host` header, so no `/etc/hosts` change is needed:
`curl -H 'Host: shop.ckad.local' http://127.0.0.1/web`

Helm/kustomize exercises use the installed `helm` (v4) and `kubectl -k` / `kustomize`.
Exercise 14 does not run `helm repo add` in its scripts (it uses `--repo <url>`), so your helm config is not changed.
While 14 is installed, Ingresses created without a class get `nginx`, so run its teardown before doing 05.
28 installs ingress-nginx too (not as default), or reuses the one from 14 if it is there.
29 installs a second, Gateway-API-only traefik (`gateway-system`, NodePort 30180). k3s's own traefik is never changed.
