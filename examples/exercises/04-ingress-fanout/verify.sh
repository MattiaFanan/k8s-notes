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

LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -z "$LB_IP" ]; then
  LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
fi
if [ -z "$LB_IP" ]; then
  LB_IP="127.0.0.1"
fi

http_lb() { curl -s -m 5 -H "Host: $1" "http://$LB_IP$2"; }

check "shop /web      -> web"        eq "$(http_lb shop.ckad.local /web)" web
check "shop /web/x    -> web"        eq "$(http_lb shop.ckad.local /web/x)" web
check "shop /api/v1   -> api"        eq "$(http_lb shop.ckad.local /api/v1)" api
check "shop /healthz  -> web"        eq "$(http_lb shop.ckad.local /healthz)" web
check "shop /healthz/x -> not routed" no eq "$(http_lb shop.ckad.local /healthz/x)" web
check "shop /other    -> 404"        eq "$(curl -s -o /dev/null -w '%{http_code}' -m 5 -H 'Host: shop.ckad.local' http://$LB_IP/other)" 404
check "admin /anything -> api"       eq "$(http_lb admin.ckad.local /anything)" api
summary
