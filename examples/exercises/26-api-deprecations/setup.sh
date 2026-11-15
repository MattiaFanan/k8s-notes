#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W/old" "$W/new"
ns api-26
cat > "$W/old/deployment.yaml" <<'YAML'
apiVersion: extensions/v1beta1
kind: Deployment
metadata: {name: web, namespace: api-26}
spec:
  replicas: 2
  template:
    metadata: {labels: {app: web}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        resources: {requests: {cpu: 50m}}
YAML
cat > "$W/old/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata: {name: web, namespace: api-26}
spec:
  selector: {app: web}
  ports: [{port: 80}]
YAML
cat > "$W/old/ingress.yaml" <<'YAML'
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web
  namespace: api-26
  annotations: {kubernetes.io/ingress.class: traefik}
spec:
  rules:
  - host: web.ckad.local
    http:
      paths:
      - path: /
        backend: {serviceName: web, servicePort: 80}
YAML
cat > "$W/old/cronjob.yaml" <<'YAML'
apiVersion: batch/v1beta1
kind: CronJob
metadata: {name: nightly, namespace: api-26}
spec:
  schedule: "0 1 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers: [{name: c, image: busybox:1.36, command: [echo, nightly]}]
YAML
cat > "$W/old/pdb.yaml" <<'YAML'
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata: {name: web, namespace: api-26}
spec:
  minAvailable: 1
  selector: {matchLabels: {app: web}}
YAML
cat > "$W/old/hpa.yaml" <<'YAML'
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata: {name: web, namespace: api-26}
spec:
  scaleTargetRef: {apiVersion: extensions/v1beta1, kind: Deployment, name: web}
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource: {name: cpu, targetAverageUtilization: 50}
YAML
echo "old manifests in $W/old, write fixed ones to $W/new"
