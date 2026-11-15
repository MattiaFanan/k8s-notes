# 06 – Solution

## Diagnosis
```bash
kubectl describe ing store -n ingress-06
#   store.ckad.local  /  store-svc:8080 (<error: services "store-svc" not found>)
kubectl get svc -n ingress-06                 # the service is called "store", port 80
kubectl get endpointslices -n ingress-06      # store has no endpoints
kubectl get svc store -n ingress-06 -o jsonpath='{.spec.selector}'   # {"app":"shop"}
kubectl get pods -n ingress-06 --show-labels                         # app=store
```
Three bugs:
1. The Ingress backend names `store-svc`, but the Service is `store`.
2. The Ingress backend port is `8080`, but the Service port is `80`.
3. The Service selector `app=shop` matches no pod, so there are no endpoints. Traefik would answer 503 or 404.

Fix the Service (the Deployment must not change):
```bash
kubectl patch svc store -n ingress-06 --type merge -p '{"spec":{"selector":{"app":"store"}}}'
# or: kubectl edit svc store -n ingress-06
```

## TLS
```bash
openssl req -x509 -nodes -newkey rsa:2048 -days 30 -subj "/CN=store.ckad.local" \
  -addext "subjectAltName=DNS:store.ckad.local" -keyout store.key -out store.crt
kubectl create secret tls store-tls -n ingress-06 --cert=store.crt --key=store.key
kubectl apply -f ingress.yaml        # fixed backend + tls section
```
- A TLS secret has `type: kubernetes.io/tls` and keys `tls.crt` / `tls.key`. `kubectl create secret tls` builds it for you.
- The secret must be in the **same namespace** as the Ingress.
- `spec.tls[].hosts` must match the rule host. The controller picks the cert by SNI. Without a match traefik serves
  its own default cert (CN `TRAEFIK DEFAULT CERT`).
- Imperative alternative: `kubectl create ingress store -n ingress-06 --class=traefik --rule='store.ckad.local/*=store:80,tls=store-tls'`.
- Check the served cert: `openssl s_client -connect 127.0.0.1:443 -servername store.ckad.local </dev/null | openssl x509 -noout -subject`.
