#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; N="-n api-26"
echo "Files"
check "work/new applies cleanly (server dry-run)" kubectl apply --dry-run=server -f "$W/new/"
check "work/old untouched (still broken)" no kubectl apply --dry-run=server -f "$W/old/deployment.yaml"
echo "Objects"
check "deploy web 2 ready"               eq "$(get deploy web $N -o jsonpath='{.status.readyReplicas}')" 2
check "deploy has selector app=web"      eq "$(get deploy web $N -o jsonpath='{.spec.selector.matchLabels.app}')" web
check "ingress backend web:80"           eq "$(get ing web $N -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}:{.spec.rules[0].http.paths[0].backend.service.port.number}')" web:80
check "ingress pathType set"             test -n "$(get ing web $N -o jsonpath='{.spec.rules[0].http.paths[0].pathType}')"
check "ingress uses spec.ingressClassName traefik" eq "$(get ing web $N -o jsonpath='{.spec.ingressClassName}')" traefik
sleep 3
check "ingress serves"                   has "$(http web.ckad.local /)" nginx
check "cronjob nightly"                  eq "$(get cronjob nightly $N -o jsonpath='{.spec.schedule}')" "0 1 * * *"
check "pdb web minAvailable 1"           eq "$(get pdb web $N -o jsonpath='{.spec.minAvailable}')" 1
check "hpa targets apps/v1 Deployment web" eq "$(get hpa web $N -o jsonpath='{.spec.scaleTargetRef.apiVersion}/{.spec.scaleTargetRef.name}')" apps/v1/web
check "hpa cpu 50% utilization, 1-3"     eq "$(get hpa web $N -o jsonpath='{.spec.metrics[0].resource.target.averageUtilization} {.spec.minReplicas}-{.spec.maxReplicas}')" "50 1-3"
summary
