#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=ingress-04
ing() { get ingress shop -n $N -o jsonpath="$1"; }
echo "Ingress shop spec"
check "exists"                       get ingress shop -n $N
check "ingressClassName traefik"     eq "$(ing '{.spec.ingressClassName}')" traefik
check "/api uses port name http"     eq "$(ing '{.spec.rules[?(@.host=="shop.ckad.local")].http.paths[?(@.path=="/api")].backend.service.port.name}')" http
check "/web uses port number 8080"   eq "$(ing '{.spec.rules[?(@.host=="shop.ckad.local")].http.paths[?(@.path=="/web")].backend.service.port.number}')" 8080
check "/healthz pathType Exact"      eq "$(ing '{.spec.rules[?(@.host=="shop.ckad.local")].http.paths[?(@.path=="/healthz")].pathType}')" Exact
sleep 2   # give traefik a moment to pick up changes
echo "Routing through traefik"
check "shop /web      -> web"        eq "$(http shop.ckad.local /web)" web
check "shop /web/x    -> web"        eq "$(http shop.ckad.local /web/x)" web
check "shop /api/v1   -> api"        eq "$(http shop.ckad.local /api/v1)" api
check "shop /healthz  -> web"        eq "$(http shop.ckad.local /healthz)" web
check "shop /healthz/x -> not routed" no eq "$(http shop.ckad.local /healthz/x)" web
check "shop /other    -> 404"        eq "$(curl -s -o /dev/null -w '%{http_code}' -m 5 -H 'Host: shop.ckad.local' http://127.0.0.1/other)" 404
check "admin /anything -> api"       eq "$(http admin.ckad.local /anything)" api
summary
