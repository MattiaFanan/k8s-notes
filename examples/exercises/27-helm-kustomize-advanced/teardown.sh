#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
helm uninstall plat -n helm-27 2>/dev/null
kubectl delete ns helm-27 helm-27-kust --ignore-not-found
rm -rf "$(dirname "$0")/work"
