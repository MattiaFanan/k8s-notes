# Path-based Ingress routing to two services

**Task:** Route `/app1` to service `app1-svc:80` and `/app2` to service `app2-svc:80` on host `shop.example.com`, ingressClassName `nginx`.

**Fastest route:** no imperative `kubectl create ingress` supports multiple paths cleanly in one line for both, so create one path then edit:
```bash
k create ingress shop-ingress --class=nginx \
  --rule="shop.example.com/app1=app1-svc:80" \
  --rule="shop.example.com/app2=app2-svc:80"
```

**Verify:**
```bash
k get ingress shop-ingress
k describe ingress shop-ingress   # confirm both paths + backends listed
```

**Gotcha:** default `pathType` from `kubectl create ingress` is `ImplementationSpecific` — if the task specifies `Prefix` or `Exact` explicitly, generate with `$do` first and patch `pathType` in the YAML. Multiple `--rule` flags in one command is the key trick to avoid hand-writing YAML.
