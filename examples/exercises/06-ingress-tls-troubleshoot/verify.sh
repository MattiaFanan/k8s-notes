#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=ingress-06
echo "Deployment untouched"
check "store deploy still has label app=store" eq "$(get deploy store -n $N -o jsonpath='{.spec.template.metadata.labels.app}')" store
echo "Service / endpoints"
check "service store has endpoints" has "$(get endpointslices -n $N -l kubernetes.io/service-name=store -o jsonpath='{.items[*].endpoints[*].addresses[*]}')" .
sleep 2
check "HTTP store.ckad.local -> store" eq "$(http store.ckad.local /)" store
echo "TLS"
check "secret store-tls is kubernetes.io/tls" eq "$(get secret store-tls -n $N -o jsonpath='{.type}')" kubernetes.io/tls
check "ingress tls uses store-tls"   eq "$(get ing store -n $N -o jsonpath='{.spec.tls[0].secretName}')" store-tls
check "ingress tls host"             has "$(get ing store -n $N -o jsonpath='{.spec.tls[0].hosts[*]}')" store.ckad.local
check "HTTPS store.ckad.local -> store" eq "$(curl -sk -m 5 --resolve store.ckad.local:443:127.0.0.1 https://store.ckad.local/)" store
SUBJ=$(openssl s_client -connect 127.0.0.1:443 -servername store.ckad.local </dev/null 2>/dev/null | openssl x509 -noout -subject 2>/dev/null)
check "served cert CN=store.ckad.local" has "$SUBJ" "CN *= *store.ckad.local"
summary
