#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
c() { curl -s -m 5 -H "Host: $1" "${@:3}" "http://127.0.0.1:30180$2"; }
cond() { get "$1" -n "$2" -o jsonpath="{.status.$3}"; }
echo "GatewayClass / Gateway"
check "GatewayClass ckad-gw controller" eq "$(get gatewayclass ckad-gw -o jsonpath='{.spec.controllerName}')" traefik.io/gateway-controller
check "GatewayClass Accepted"         eq "$(get gatewayclass ckad-gw -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}')" True
check "Gateway web-gw uses ckad-gw"   eq "$(get gateway web-gw -n gateway-system -o jsonpath='{.spec.gatewayClassName}')" ckad-gw
check "listener http :8000 *.ckad.local" eq "$(get gateway web-gw -n gateway-system -o jsonpath='{.spec.listeners[0].protocol} {.spec.listeners[0].port} {.spec.listeners[0].hostname}')" "HTTP 8000 *.ckad.local"
check "allowedRoutes from Selector gateway-access=true" eq "$(get gateway web-gw -n gateway-system -o jsonpath='{.spec.listeners[0].allowedRoutes.namespaces.from} {.spec.listeners[0].allowedRoutes.namespaces.selector.matchLabels.gateway-access}')" "Selector true"
check "Gateway Accepted"              eq "$(get gateway web-gw -n gateway-system -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}')" True
check "ns gw-29 labelled, gw-29-blocked not" eq "$(get ns gw-29 -o jsonpath='{.metadata.labels.gateway-access}')/$(get ns gw-29-blocked -o jsonpath='{.metadata.labels.gateway-access}')" true/
echo "Routes"
check "route store Accepted"          eq "$(cond httproute/store gw-29 'parents[0].conditions[?(@.type=="Accepted")].status')" True
check "route admin Accepted"          eq "$(cond httproute/admin gw-29 'parents[0].conditions[?(@.type=="Accepted")].status')" True
check "route sneaky NOT accepted"     no eq "$(cond httproute/sneaky gw-29-blocked 'parents[0].conditions[?(@.type=="Accepted")].status')" True
sleep 2
echo "Traffic"
ok=1; for i in 1 2 3 4 5; do eq "$(c store.ckad.local / -H 'X-Version: v2')" store-v2 || ok=0; done
check "X-Version: v2 -> store-v2 (5/5)" test $ok = 1
R=$(for i in $(seq 40); do c store.ckad.local /; echo; done)
V1=$(grep -c '^store-v1$' <<<"$R"); V2=$(grep -c '^store-v2$' <<<"$R")
check "no header: both versions answer ($V1 v1 / $V2 v2 of 40)" test "$V1" -gt 0 -a "$V2" -gt 0
check "no header: v1 is the majority" test "$V1" -gt "$V2"
check "admin /admin -> admin"         eq "$(c admin.ckad.local /admin)" admin
check "admin adds X-Served-By header" has "$(c admin.ckad.local /admin -i)" "X-Served-By: gateway-api"
check "admin /other -> 404"           eq "$(curl -s -o /dev/null -w '%{http_code}' -m 5 -H 'Host: admin.ckad.local' http://127.0.0.1:30180/other)" 404
check "sneaky.ckad.local -> 404"      eq "$(curl -s -o /dev/null -w '%{http_code}' -m 5 -H 'Host: sneaky.ckad.local' http://127.0.0.1:30180/)" 404
summary
