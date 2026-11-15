#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(dirname "$0"); W="$D/../../exercises/31-configmap-secret/work"; N="-n config-31"
kubectl create cm app-config $N --from-literal=APP_MODE=prod --from-literal=APP_COLOR=blue --from-file="$W/app.properties"
kubectl create secret generic db-creds $N --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cr3t
kubectl apply -f "$D/app.yaml"
kubectl wait pod/app $N --for=condition=Ready --timeout=120s
sed -i 's/log.level=info/log.level=debug/' "$W/app.properties"
kubectl create cm app-config $N --from-literal=APP_MODE=staging --from-literal=APP_COLOR=blue --from-file="$W/app.properties" --dry-run=client -o yaml | kubectl apply -f -
kubectl create cm frozen $N --from-literal=VERSION=1 --dry-run=client -o yaml | kubectl patch --local -f - -p '{"immutable":true}' -o yaml | kubectl apply -f -
kubectl get secret db-creds $N -o jsonpath='{.data.DB_PASSWORD}' | base64 -d > "$W/password.txt"
echo "waiting for the kubelet to refresh the mounted ConfigMap (up to 2 min)..."
for _ in $(seq 60); do kubectl exec app $N -- grep -q debug /etc/config/app.properties 2>/dev/null && break; sleep 2; done
