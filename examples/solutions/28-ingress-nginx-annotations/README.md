# 28 – Solution

```bash
printf 'ckad:%s\n' "$(openssl passwd -apr1 exam)" > auth     # or: htpasswd -c auth ckad
kubectl create secret generic basic-auth -n ann-28 --from-file=auth
kubectl apply -f ingresses.yaml
curl -H 'Host: ann.ckad.local' http://127.0.0.1:30080/app/hello            # GET /hello
curl -i -H 'Host: secure.ckad.local' http://127.0.0.1:30080/                # 401
curl -u ckad:exam -H 'Host: secure.ckad.local' http://127.0.0.1:30080/      # 200
curl -H 'X-Canary: always' -H 'Host: canary.ckad.local' http://127.0.0.1:30080/   # Hostname: whoami-v2-...
```

## Key points
- Annotations are **controller-specific**: `nginx.ingress.kubernetes.io/*` means nothing to traefik (traefik uses
  Middlewares instead). Exam tasks that use annotations tell you which controller is installed. Look at `kubectl get ingressclass`.
- **rewrite-target** with capture groups needs a regex path (`use-regex`, `pathType: ImplementationSpecific`).
  `/app(/|$)(.*)` + `/$2` removes the `/app` prefix.
- **Basic auth**: Secret key `auth` with `user:hash` lines (htpasswd format). The Secret is in the Ingress namespace.
- **Canary**: a second Ingress with the same host/path and `canary: "true"`. Pick traffic by `canary-by-header`
  (`always`/`never`), `canary-by-header-value`, `canary-by-cookie`, or a share with `canary-weight: "20"`. Without a canary
  annotation, two Ingresses with the same host and path would conflict.
- Debug: `kubectl describe ing <name>` (events from the controller) and
  `kubectl logs -n ingress-nginx deploy/ingress-nginx-controller`. Invalid annotations are rejected by the controller's admission webhook.
