#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W"
ns users-09
sha256sum "$KUBECONFIG" | cut -d' ' -f1 > "$W/.k3s.sha"
echo "namespace users-09 ready, work dir: $W"
