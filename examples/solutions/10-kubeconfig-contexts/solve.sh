#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
cd "$(dirname "$0")/../../exercises/10-kubeconfig-contexts/work"
export KUBECONFIG=$PWD/multi.kubeconfig          # this shell only
kubectl config get-contexts -o name > contexts.txt
kubectl config current-context > current.txt
kubectl config view -o jsonpath='{.clusters[?(@.name=="prod")].cluster.server}' > prod-server.txt
kubectl config set-context team-a --cluster=k3s --user=k3s-admin --namespace=team-a
kubectl config delete-context old-ctx
kubectl config delete-user old-user
kubectl config set-context prod-admin --namespace=payments
kubectl config use-context team-a
kubectl create namespace team-a
kubectl create configmap hello --from-literal=msg=world
KUBECONFIG=$PWD/multi.kubeconfig:$PWD/extra.kubeconfig kubectl config view --flatten > merged.kubeconfig
