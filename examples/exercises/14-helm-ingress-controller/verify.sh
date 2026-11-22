#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
R=$(helm list -n ingress-nginx -o json 2>/dev/null | jq -c '.[] | select(.name=="ingress-nginx")')
V=$(helm get values ingress-nginx -n ingress-nginx -o json 2>/dev/null)
echo "Helm release"
check "release ingress-nginx deployed" eq "$(jq -r .status <<<"$R" 2>/dev/null)" deployed
check "chart ingress-nginx-4.15.1"     eq "$(jq -r .chart <<<"$R" 2>/dev/null)" ingress-nginx-4.15.1
check "values: service NodePort"       eq "$(jq -r .controller.service.type <<<"$V" 2>/dev/null)" NodePort
check "values: default class true"     eq "$(jq -r .controller.ingressClassResource.default <<<"$V" 2>/dev/null)" true
echo "Cluster"
check "controller deployment available" kubectl wait -n ingress-nginx --for=condition=Available deploy/ingress-nginx-controller --timeout=5s
check "service nodePort http 30080"    eq "$(get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')" 30080
check "IngressClass nginx is default"  eq "$(get ingressclass nginx -o jsonpath='{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}')" true
check "IngressClass nginx controller k8s.io/ingress-nginx" eq "$(get ingressclass nginx -o jsonpath='{.spec.controller}')" k8s.io/ingress-nginx
check "traefik IngressClass untouched (still default)" eq "$(get ingressclass traefik -o jsonpath='{.metadata.annotations.ingressclass\.kubernetes\.io/is-default-class}')" true
check "ingress echo got class nginx"   eq "$(get ing echo -n helm-14 -o jsonpath='{.spec.ingressClassName}')" nginx
sleep 2


LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -z "$LB_IP" ]; then
  LB_IP=$(kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
fi
if [ -z "$LB_IP" ]; then
  LB_IP="127.0.0.1"
fi

echo "Routing"
check "via ingress-nginx :30080 -> echo" eq "$(curl -s -m 5 -H 'Host: echo.ckad.local' http://$LB_IP:30080/)" echo
check "via traefik :80 -> 404"         eq "$(curl -s -o /dev/null -w '%{http_code}' -m 5 -H 'Host: echo.ckad.local' http://$LB_IP/)" 404
summary
