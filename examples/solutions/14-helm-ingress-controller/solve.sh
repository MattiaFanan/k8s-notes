#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
# --repo instead of 'helm repo add' so the local helm repo config is not changed
helm install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --version 4.15.1 \
  -n ingress-nginx --create-namespace -f $D/values.yaml --wait --timeout 5m
kubectl apply -f $D/ingress.yaml
for i in $(seq 30); do [ "$(curl -s -m 2 -H 'Host: echo.ckad.local' http://127.0.0.1:30080/)" = echo ] && break; sleep 2; done
