#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
ns sa-08; ns sa-08-other
kubectl create svc clusterip backend -n sa-08-other --tcp=80:80 --dry-run=client -o yaml | kubectl apply -f -
