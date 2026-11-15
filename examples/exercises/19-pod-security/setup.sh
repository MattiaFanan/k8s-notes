#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W"
ns psa-19
cat > "$W/bad-pod.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata: {name: bad, namespace: psa-19}
spec:
  hostNetwork: true
  containers:
  - name: c
    image: busybox:1.36
    command: [sleep, "3600"]
    securityContext:
      privileged: true
      runAsUser: 0
YAML
echo "namespace psa-19 ready, see $W/bad-pod.yaml"
