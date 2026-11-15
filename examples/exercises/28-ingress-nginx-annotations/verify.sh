#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n ann-28"
c() { curl -s -m 5 -H "Host: $1" "${@:3}" "http://127.0.0.1:30080$2"; }
code() { curl -s -o /dev/null -w '%{http_code}' -m 5 -H "Host: $1" "${@:3}" "http://127.0.0.1:30080$2"; }
echo "Ingresses use class nginx"
for i in rewrite secure main main-canary; do check "$i" eq "$(get ing $i $N -o jsonpath='{.spec.ingressClassName}')" nginx; done
echo "Rewrite"
check "/app/hello reaches backend as /hello" has "$(c ann.ckad.local /app/hello)" "GET /hello HTTP"
check "/app reaches backend as /"      has "$(c ann.ckad.local /app)" "GET / HTTP"
echo "Basic auth"
check "secret basic-auth has key auth" test -n "$(get secret basic-auth $N -o jsonpath='{.data.auth}')"
check "no credentials -> 401"          eq "$(code secure.ckad.local /)" 401
check "wrong password -> 401"          eq "$(code secure.ckad.local / -u ckad:nope)" 401
check "ckad:exam -> 200"               eq "$(code secure.ckad.local / -u ckad:exam)" 200
echo "Canary"
check "main-canary has canary annotation" eq "$(get ing main-canary $N -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/canary}')" true
ok=1; for i in 1 2 3 4 5; do has "$(c canary.ckad.local / -H 'X-Canary: always')" "Hostname: whoami-v2" || ok=0; done
check "X-Canary: always -> whoami-v2 (5/5)" test $ok = 1
ok=1; for i in 1 2 3 4 5; do r=$(c canary.ckad.local /); has "$r" "Hostname: whoami-" && ! has "$r" "whoami-v2" || ok=0; done
check "no header -> whoami (5/5)"      test $ok = 1
summary
