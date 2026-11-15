# 29 – Gateway API: GatewayClass, Gateway, HTTPRoute

Run `./setup.sh` first. k3s ships the Gateway API CRDs, but its traefik does not run the gateway provider.
Instead of changing k3s's traefik, setup installs a **second** traefik with Helm (release `traefik-gw`,
namespace `gateway-system`) that handles **only** Gateway API objects. Its `web` entrypoint listens on container port `8000`
and is exposed on NodePort `30180`.

Namespace `gw-29` has Services `store-v1`, `store-v2`, `admin` (port 80, they answer their own name).
Namespace `gw-29-blocked` has an HTTPRoute `sneaky` (host `sneaky.ckad.local`) that tries to use your Gateway.

1. GatewayClass `ckad-gw` for controller `traefik.io/gateway-controller`. Check that it is `Accepted`.
2. Gateway `web-gw` in `gateway-system` (class `ckad-gw`) with one listener `http`: protocol HTTP, port `8000`,
   hostname `*.ckad.local`. Routes may attach **only** from namespaces labelled `gateway-access=true`.
3. Allow `gw-29` to attach routes (but not `gw-29-blocked`).
4. HTTPRoute `store` in `gw-29` on `web-gw`, hostname `store.ckad.local`:
   - requests with header `X-Version: v2` -> always `store-v2`
   - all other requests on `/` -> `store-v1` with weight 80 and `store-v2` with weight 20
5. HTTPRoute `admin` in `gw-29`, hostname `admin.ckad.local`: path prefix `/admin` -> `admin`, and add the
   response header `X-Served-By: gateway-api`.
6. Look at the status of route `sneaky`. Why is it not working?

Test: `curl -H 'Host: store.ckad.local' http://127.0.0.1:30180/`

Check with `./verify.sh`, clean up with `./teardown.sh`.
