#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/gateway.yaml
kubectl label ns gw-29 gateway-access=true --overwrite
kubectl apply -f $D/routes.yaml
kubectl wait gateway/web-gw -n gateway-system --for=condition=Accepted --timeout=60s
for i in $(seq 30); do [ "$(curl -s -m 2 -H 'Host: admin.ckad.local' http://127.0.0.1:30180/admin)" = admin ] && break; sleep 2; done
