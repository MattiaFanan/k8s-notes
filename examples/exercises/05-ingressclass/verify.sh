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
check "internal.ckad.local -> hello" eq "$(http internal.ckad.local /)" hello
check "default.ckad.local  -> hello" eq "$(http default.ckad.local /)" hello
check "legacy.ckad.local   -> hello" eq "$(http legacy.ckad.local /)" hello
summary
