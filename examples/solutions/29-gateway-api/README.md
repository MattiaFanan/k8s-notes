# 29 – Solution

```bash
kubectl apply -f gateway.yaml
kubectl get gatewayclass ckad-gw          # ACCEPTED True
kubectl get gateway -n gateway-system     # PROGRAMMED ...
kubectl label ns gw-29 gateway-access=true
kubectl apply -f routes.yaml
kubectl get httproute -A
kubectl describe httproute sneaky -n gw-29-blocked    # Accepted False, reason NotAllowedByListeners
for i in $(seq 10); do curl -s -H 'Host: store.ckad.local' http://127.0.0.1:30180/; echo; done
curl -H 'X-Version: v2' -H 'Host: store.ckad.local' http://127.0.0.1:30180/
curl -i -H 'Host: admin.ckad.local' http://127.0.0.1:30180/admin       # X-Served-By: gateway-api
```

## Key points
- **Role split**: GatewayClass (cluster admin / infrastructure provider) -> Gateway (platform team: ports, hostnames,
  TLS, who may attach) -> HTTPRoute (app team, in their own namespace). With Ingress all of that is in one object, plus annotations.
- **Things that are only annotations in Ingress are in the spec here**: header/query/method matching, weighted traffic splitting,
  header modification, redirects and URL rewrites (`filters`), cross-namespace attachment. Because they are in the spec, they work the same with every controller.
- `allowedRoutes.namespaces.from`: `Same` (default: only the Gateway's namespace), `All`, or `Selector`. That is why
  `sneaky` stays unattached (`Accepted: False, NotAllowedByListeners`) and its host returns 404.
- A route attaches with `parentRefs` (namespace + name, optional `sectionName` = listener name). The route hostname must
  match the listener hostname (`*.ckad.local`).
- Backends in **another** namespace need a `ReferenceGrant` in the backend's namespace.
- `kubectl get <route> -o yaml` → `status.parents[].conditions` (`Accepted`, `ResolvedRefs`) is the first place to look when debugging.
- The listener port is the port the **controller** listens on. With traefik that is the entrypoint's container port (8000),
  not the Service port 80 or the NodePort.
