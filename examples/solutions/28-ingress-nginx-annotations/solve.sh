#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
T=$(mktemp)
printf 'ckad:%s\n' "$(openssl passwd -apr1 exam)" > $T
kubectl create secret generic basic-auth -n ann-28 --from-file=auth=$T
rm -f $T
kubectl apply -f "$(dirname "$0")"/ingresses.yaml
for i in $(seq 30); do [ "$(curl -s -o /dev/null -w '%{http_code}' -m 2 -H 'Host: secure.ckad.local' http://127.0.0.1:30080/)" = 401 ] && break; sleep 2; done
sleep 3
