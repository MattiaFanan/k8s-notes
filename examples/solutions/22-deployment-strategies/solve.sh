#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n deploy-22"
kubectl apply -f "$(dirname "$0")"/green.yaml
kubectl rollout status deploy/green $N --timeout=120s
kubectl patch svc shop $N -p '{"spec":{"selector":{"app":"shop","version":"green"}}}'
kubectl patch deploy catalog $N -p '{"spec":{"strategy":{"type":"RollingUpdate","rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
kubectl patch deploy catalog $N --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/args/0","value":"-text=catalog-v1.1"}]'
kubectl annotate deploy catalog $N kubernetes.io/change-cause="bump to v1.1" --overwrite
kubectl rollout status deploy/catalog $N --timeout=120s
kubectl rollout undo deploy/catalog $N --to-revision=1
kubectl rollout status deploy/catalog $N --timeout=120s
kubectl rollout status deploy/catalog-canary $N --timeout=120s
