#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); N="-n hpa-30"
kubectl set resources deploy api $N --requests=cpu=100m,memory=64Mi
kubectl rollout status deploy/api $N --timeout=180s
kubectl apply -f "$D/hpa.yaml"
kubectl get pod load $N >/dev/null 2>&1 || kubectl run load $N --image=busybox:1.36 -- /bin/sh -c "while true; do wget -q -O- http://api; done"
echo "waiting for the HPA to scale up (up to 4 min)..."
for _ in $(seq 120); do [ -n "$(kubectl get hpa api $N -o jsonpath='{.status.lastScaleTime}')" ] && break; sleep 2; done
kubectl get hpa api $N
