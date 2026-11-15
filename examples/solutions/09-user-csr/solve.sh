#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
D=$(cd "$(dirname "$0")" && pwd); W="$D/../../exercises/09-user-csr/work"; mkdir -p "$W"; cd "$W"
# 1. key + CSR
openssl genrsa -out jane.key 2048 2>/dev/null
openssl req -new -key jane.key -subj "/CN=jane/O=dev-team" -out jane.csr
# 2. CSR object, approve, fetch cert
CSR_B64=$(base64 -w0 jane.csr) envsubst < "$D/csr.yaml.tpl" | kubectl apply -f -
kubectl certificate approve jane
until [ -n "$(kubectl get csr jane -o jsonpath='{.status.certificate}')" ]; do sleep 1; done
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt
# 3. new kubeconfig (server + CA copied from the existing one, read-only)
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
K="--kubeconfig=jane.kubeconfig"
kubectl config $K set-cluster k3s --server="$SERVER" --certificate-authority=ca.crt --embed-certs=true
kubectl config $K set-credentials jane --client-certificate=jane.crt --client-key=jane.key --embed-certs=true
kubectl config $K set-context jane@k3s --cluster=k3s --user=jane --namespace=users-09
kubectl config $K use-context jane@k3s
rm ca.crt
# 4. RBAC (as admin)
kubectl apply -f "$D/rbac.yaml"
# 5. as jane
kubectl $K create deployment jane-app --image=nginx:1.27-alpine
