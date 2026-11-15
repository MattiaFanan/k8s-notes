# 05 – IngressClass

Run `./setup.sh` first. Namespace: `ingress-05`. Service `hello` (port 80) answers `hello`.
k3s has one IngressClass, `traefik`, handled by controller `traefik.io/ingress-controller`.

1. Find the default IngressClass and its controller name.
2. Create an IngressClass `traefik-internal` for the same controller (`traefik.io/ingress-controller`).
   It must **not** be default.
3. Create an Ingress `hello-internal` with class `traefik-internal`: host `internal.ckad.local`, `/` (Prefix) -> `hello:80`.
4. Create an Ingress `hello-default` **without** setting any class: host `default.ckad.local`, `/` -> `hello:80`.
   Then look at its `spec.ingressClassName`. Who set it?
5. Setup created an Ingress `legacy` (host `legacy.ckad.local`) that traefik ignores.
   Find out why and fix it so traefik serves it, using the **current** way to select a class.
6. All three must answer:
   ```bash
   curl -H 'Host: internal.ckad.local' http://127.0.0.1/   # hello
   curl -H 'Host: default.ckad.local'  http://127.0.0.1/   # hello
   curl -H 'Host: legacy.ckad.local'   http://127.0.0.1/   # hello
   ```

Check with `./verify.sh`, clean up with `./teardown.sh`.
