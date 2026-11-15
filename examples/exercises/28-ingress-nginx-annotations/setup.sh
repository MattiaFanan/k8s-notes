#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; mkdir -p "$W"
if helm status ingress-nginx -n ingress-nginx >/dev/null 2>&1; then
  echo "reusing the ingress-nginx release from exercise 14"; touch "$W/.reused"
else
  # shortcut: --repo instead of 'helm repo add', so the local helm config is not changed
  helm install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --version 4.15.1 \
    -n ingress-nginx --create-namespace --wait --timeout 5m \
    --set controller.service.type=NodePort --set controller.service.nodePorts.http=30080 \
    --set controller.service.nodePorts.https=30443 --set controller.ingressClassResource.name=nginx \
    --set controller.ingressClassResource.default=false
fi
ns ann-28
for a in whoami whoami-v2; do
  kubectl create deploy $a -n ann-28 --image=traefik/whoami:v1.10.3 --dry-run=client -o yaml | kubectl apply -f -
  kubectl create svc clusterip $a -n ann-28 --tcp=80:80 --dry-run=client -o yaml | kubectl apply -f -
done
kubectl wait -n ann-28 --for=condition=Available deploy --all --timeout=120s
