#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n jobs-23"
kubectl apply -f "$(dirname "$0")"/jobs.yaml
kubectl create job reporter-manual --from=cronjob/reporter $N
kubectl wait $N job/batch job/indexed job/reporter-manual --for=condition=Complete --timeout=180s
kubectl wait $N job/failer --for=condition=Failed --timeout=180s
