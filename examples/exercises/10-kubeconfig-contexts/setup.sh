#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; rm -rf "$W"; mkdir -p "$W"
sha256sum "$KUBECONFIG" | cut -d' ' -f1 > "$W/.k3s.sha"
T=$(mktemp -d)
# copy the real credentials out of the existing kubeconfig (read-only)
kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > $T/ca.crt
kubectl config view --raw --minify -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d > $T/admin.crt
kubectl config view --raw --minify -o jsonpath='{.users[0].user.client-key-data}' | base64 -d > $T/admin.key
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
K="kubectl config --kubeconfig=$W/multi.kubeconfig"
$K set-cluster k3s  --server="$SERVER" --certificate-authority=$T/ca.crt --embed-certs=true >/dev/null
$K set-cluster prod --server=https://10.255.255.1:6443 --insecure-skip-tls-verify=true >/dev/null
$K set-credentials k3s-admin --client-certificate=$T/admin.crt --client-key=$T/admin.key --embed-certs=true >/dev/null
$K set-credentials prod-admin --token=not-a-real-token >/dev/null
$K set-credentials old-user --token=old-token >/dev/null
$K set-context k3s-admin  --cluster=k3s  --user=k3s-admin >/dev/null
$K set-context prod-admin --cluster=prod --user=prod-admin --namespace=default >/dev/null
$K set-context old-ctx    --cluster=prod --user=old-user >/dev/null
$K use-context prod-admin >/dev/null
X="kubectl config --kubeconfig=$W/extra.kubeconfig"
$X set-cluster staging --server=https://10.255.255.2:6443 --insecure-skip-tls-verify=true >/dev/null
$X set-credentials staging-dev --token=staging-token >/dev/null
$X set-context staging-dev --cluster=staging --user=staging-dev --namespace=dev >/dev/null
$X use-context staging-dev >/dev/null
rm -rf $T
kubectl delete ns team-a --ignore-not-found >/dev/null
echo "created $W/multi.kubeconfig and $W/extra.kubeconfig"
