# 28 – Ingress controller annotations (ingress-nginx): rewrite, basic auth, canary

Run `./setup.sh` first. It installs ingress-nginx with Helm (class `nginx`, **not** default, NodePort `30080`)
unless exercise 14 has already installed it. Namespace: `ann-28`, with Deployments/Services `whoami` and `whoami-v2`
(port 80). `traefik/whoami` prints its pod name (`Hostname:`) and the request line it received (`GET /path HTTP/1.1`).

All Ingresses use class `nginx`. Test with `curl -H 'Host: <host>' http://127.0.0.1:30080/...`.

1. **Rewrite**: Ingress `rewrite`, host `ann.ckad.local`. Requests to `/app/<anything>` reach `whoami` as `/<anything>`.
   `curl -H 'Host: ann.ckad.local' http://127.0.0.1:30080/app/hello` shows `GET /hello`.
2. **Basic auth**: Ingress `secure`, host `secure.ckad.local`, `/` -> `whoami`, protected with user `ckad` / password `exam`.
   The credentials go in a Secret `basic-auth` (htpasswd format, key `auth`). Without credentials: 401.
3. **Canary by header**: Ingress `main` (host `canary.ckad.local`, `/` -> `whoami`) plus a canary Ingress `main-canary`
   (same host and path, -> `whoami-v2`) that receives the request **only** when the header `X-Canary: always` is set.

Check with `./verify.sh`, clean up with `./teardown.sh`.
