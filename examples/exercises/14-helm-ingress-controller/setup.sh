#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns helm-14
echo_app helm-14 echo 80
kubectl wait -n helm-14 --for=condition=Available deploy/echo --timeout=120s
