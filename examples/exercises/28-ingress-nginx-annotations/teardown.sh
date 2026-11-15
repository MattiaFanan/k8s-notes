#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"
kubectl delete ns ann-28 --ignore-not-found
if [ ! -e "$W/.reused" ]; then helm uninstall ingress-nginx -n ingress-nginx --wait 2>/dev/null; kubectl delete ns ingress-nginx --ignore-not-found; fi
rm -rf "$W"
