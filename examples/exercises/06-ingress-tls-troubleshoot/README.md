# 06 – Troubleshoot an Ingress, then add TLS

Run `./setup.sh` first. Namespace: `ingress-06`.

Deployment `store` answers `store`. There is a Service and an Ingress `store` for host `store.ckad.local`,
but `curl -H 'Host: store.ckad.local' http://TRAEFIK_IP/` does not return `store`.

1. Fix it. Do **not** change the Deployment. There is more than one problem.
2. Create a self-signed certificate for `CN=store.ckad.local` with `openssl`, put it in a TLS Secret
   `store-tls`, and enable TLS for `store.ckad.local` on the Ingress.
   ```bash
   curl -k --resolve store.ckad.local:443:TRAEFIK_IP https://store.ckad.local/    # store
   ```
   The certificate served must be yours (CN `store.ckad.local`), not traefik's default.

Check with `./verify.sh`, clean up with `./teardown.sh`.
