#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); T=$(mktemp -d)
kubectl patch svc store -n ingress-06 --type merge -p '{"spec":{"selector":{"app":"store"}}}'
openssl req -x509 -nodes -newkey rsa:2048 -days 30 -subj "/CN=store.ckad.local" \
  -addext "subjectAltName=DNS:store.ckad.local" -keyout $T/store.key -out $T/store.crt 2>/dev/null
kubectl create secret tls store-tls -n ingress-06 --cert=$T/store.crt --key=$T/store.key
kubectl apply -f $D/ingress.yaml
rm -rf $T
