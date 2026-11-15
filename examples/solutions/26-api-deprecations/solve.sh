#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); W="$D/../../exercises/26-api-deprecations/work"
cp $D/new/*.yaml "$W/new/"
kubectl apply -f "$W/new/"
kubectl rollout status deploy/web -n api-26 --timeout=120s
