#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n multi-24"
kubectl apply -f "$(dirname "$0")"/web.yaml
sleep 5
kubectl create service clusterip backend $N --tcp=80:80
kubectl wait $N pod/web pod/waiter --for=condition=Ready --timeout=120s
kubectl exec $N web -c nginx -- wget -qO- 127.0.0.1
kubectl wait $N job/batch --for=condition=Complete --timeout=120s
