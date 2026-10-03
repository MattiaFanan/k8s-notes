# Install, upgrade, and roll back a Helm release

**Task:** Install chart `bitnami/nginx` as release `my-nginx` in namespace `web`, then upgrade its `replicaCount` value, then roll back.

**Fastest route:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami   # if repo not already added
helm repo update
helm install my-nginx bitnami/nginx -n web --create-namespace

helm upgrade my-nginx bitnami/nginx -n web --set replicaCount=3

helm history my-nginx -n web
helm rollback my-nginx 1 -n web
```

**Verify:**
```bash
helm list -n web
helm status my-nginx -n web
k get deploy -n web
```

**Gotcha:** CKAD exam environments usually have needed repos pre-added — check `helm repo list` before adding. `helm upgrade --install` is the idempotent one-liner if unsure whether the release already exists (avoids an install-vs-upgrade branch).
