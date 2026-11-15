#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W"
ns kust-17
cat > "$W/deployment.yaml" <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
spec:
  replicas: 1
  selector:
    matchLabels: {app: api}
  template:
    metadata:
      labels: {app: api}
    spec:
      containers:
      - name: api
        image: busybox:1.36
        command: ["sh", "-c", "sleep 3600"]
        envFrom:
        - configMapRef: {name: api-config}
        - secretRef: {name: api-secret}
        volumeMounts:
        - {name: settings, mountPath: /etc/api}
      volumes:
      - name: settings
        configMap: {name: api-config}
YAML
echo '{"feature": "beta", "timeout": 30}' > "$W/settings.json"
echo "namespace kust-17 and $W ready"
