# 04 – Solution

`ingress.yaml` is the declarative version. The same thing imperatively:
```bash
kubectl create ingress shop -n ingress-04 --class=traefik \
  --rule='shop.ckad.local/web*=web:8080' \
  --rule='shop.ckad.local/api*=api:http' \
  --rule='shop.ckad.local/healthz=web:8080' \
  --rule='admin.ckad.local/*=api:9090'
```
`--rule` syntax: `host/path=service:port`. A trailing `*` means `pathType: Prefix`, without it `Exact`.
The port can be a number or a port name.

## Key points
- `backend.service.port` is the **Service** port (8080/9090), not the container's 5678.
  Use `number:` or `name:`, never both.
- `Prefix` matches by path **segments**: `/web` matches `/web` and `/web/x`, but not `/webx`.
- `Exact` matches only that path, so `/healthz/x` falls through and traefik returns 404.
- A rule without `host` matches every host. Rules with a host match on the HTTP `Host` header,
  which is why `curl -H 'Host: …' http://127.0.0.1` works without editing `/etc/hosts`.
- Debug: `kubectl describe ingress shop -n ingress-04` shows each backend. A wrong service name or port is visible there,
  and `kubectl get endpointslices -n ingress-04` shows whether the service has pods behind it.
