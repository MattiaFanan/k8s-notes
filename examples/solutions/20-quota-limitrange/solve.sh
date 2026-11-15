#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl apply -f "$(dirname "$0")"/limits.yaml
kubectl create deploy filler -n quota-20 --image=busybox:1.36 --replicas=3 -- sleep 3600
kubectl rollout status deploy/filler -n quota-20 --timeout=120s
kubectl scale deploy filler -n quota-20 --replicas=6
sleep 10
