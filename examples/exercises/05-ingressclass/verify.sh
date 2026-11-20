#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=ingress-05
echo "IngressClass traefik-internal"
check "exists"                       get ingressclass traefik-internal
check "controller traefik.io/ingress-controller" eq "$(get ingressclass traefik-internal -o jsonpath='{.spec.controller}')" traefik.io/ingress-controller
check "not default"                  no eq "$(get ingressclass traefik-internal -o jsonpath='{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}')" true
echo "Ingresses"
check "hello-internal uses traefik-internal" eq "$(get ing hello-internal -n $N -o jsonpath='{.spec.ingressClassName}')" traefik-internal
check "hello-default got class traefik"      eq "$(get ing hello-default -n $N -o jsonpath='{.spec.ingressClassName}')" traefik
check "legacy has no ingress.class annotation" eq "$(get ing legacy -n $N -o jsonpath='{.metadata.annotations.kubernetes\.io/ingress\.class}')" ""
check "legacy uses spec.ingressClassName traefik" eq "$(get ing legacy -n $N -o jsonpath='{.spec.ingressClassName}')" traefik
sleep 2

echo "Routing"

LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -z "$LB_IP" ]; then
  LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
fi
if [ -z "$LB_IP" ]; then
  LB_IP="127.0.0.1"
fi

http_lb() { curl -s -m 5 -H "Host: $1" "http://$LB_IP$2"; }

check "internal.ckad.local -> hello" eq "$(http_lb internal.ckad.local /)" hello
check "default.ckad.local  -> hello" eq "$(http_lb default.ckad.local /)" hello
check "legacy.ckad.local   -> hello" eq "$(http_lb legacy.ckad.local /)" hello
summary
