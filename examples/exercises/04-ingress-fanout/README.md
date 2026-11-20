# 04 – Ingress fan-out: hosts, paths, pathType

Run `./setup.sh` first. Namespace: `ingress-04`. It contains two echo apps:

| Service | port (name) | answers |
|---------|-------------|---------|
| `web`   | 8080 (`http`) | `web` |
| `api`   | 9090 (`http`) | `api` |

Create **one** Ingress `shop` (class `traefik`) with these rules:

| host | path | pathType | backend |
|------|------|----------|---------|
| `shop.ckad.local`  | `/web`     | Prefix | `web`, port **number** 8080 |
| `shop.ckad.local`  | `/api`     | Prefix | `api`, port **name** `http` |
| `shop.ckad.local`  | `/healthz` | Exact  | `web`, port 8080 |
| `admin.ckad.local` | `/`        | Prefix | `api`, port 9090 |

Test it (traefik listens on localhost through a LoadBalancer):
```bash
# get traefik ip
kubectl get svc -o wide -A
```
```bash
curl -H 'Host: shop.ckad.local'  http://TRAEFIK_IP/web/x      # web
curl -H 'Host: shop.ckad.local'  http://TRAEFIK_IP/healthz/x  # 404 (Exact)
curl -H 'Host: admin.ckad.local' http://TRAEFIK_IP/anything   # api
```
Bonus: write the Ingress with `kubectl create ingress` (no YAML).

Check with `./verify.sh`, clean up with `./teardown.sh`.
