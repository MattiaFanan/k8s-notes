#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
kubectl delete ns ingress-05 --ignore-not-found
kubectl delete ingressclass traefik-internal --ignore-not-found
