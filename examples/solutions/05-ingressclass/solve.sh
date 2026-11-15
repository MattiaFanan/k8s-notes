#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0")
kubectl apply -f $D/ingressclass.yaml -f $D/ingresses.yaml
kubectl annotate ing legacy -n ingress-05 kubernetes.io/ingress.class-
kubectl patch ing legacy -n ingress-05 --type merge -p '{"spec":{"ingressClassName":"traefik"}}'
