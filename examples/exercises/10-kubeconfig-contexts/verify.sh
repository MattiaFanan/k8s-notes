#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; M="$W/multi.kubeconfig"; G="$W/merged.kubeconfig"
m() { kubectl config --kubeconfig="$M" view -o jsonpath="$1" 2>/dev/null; }
ctx() { m "{.contexts[?(@.name==\"$1\")].context.$2}"; }
echo "Original kubeconfig"
check "~/.kube/k3s.yaml unchanged"   eq "$(sha256sum "$KUBECONFIG" | cut -d' ' -f1)" "$(cat "$W/.k3s.sha" 2>/dev/null)"
echo "Reading"
check "contexts.txt = k3s-admin old-ctx prod-admin" eq "$(sort "$W/contexts.txt" 2>/dev/null | tr -s ' \n' ' ' | sed 's/ $//')" "k3s-admin old-ctx prod-admin"
check "current.txt = prod-admin"     eq "$(tr -d ' \n' < "$W/current.txt" 2>/dev/null)" prod-admin
check "prod-server.txt"              eq "$(tr -d ' \n' < "$W/prod-server.txt" 2>/dev/null)" https://10.255.255.1:6443
echo "multi.kubeconfig"
check "context team-a = k3s/k3s-admin/team-a" eq "$(ctx team-a cluster)/$(ctx team-a user)/$(ctx team-a namespace)" k3s/k3s-admin/team-a
check "context old-ctx deleted"      eq "$(ctx old-ctx cluster)" ""
check "user old-user deleted"        no has "$(m '{.users[*].name}')" old-user
check "prod-admin = prod/prod-admin/payments" eq "$(ctx prod-admin cluster)/$(ctx prod-admin user)/$(ctx prod-admin namespace)" prod/prod-admin/payments
check "current-context team-a"       eq "$(m '{.current-context}')" team-a
check "configmap hello in team-a"    eq "$(get cm hello -n team-a -o jsonpath='{.data.msg}')" world
echo "merged.kubeconfig"
g() { kubectl config --kubeconfig="$G" view --raw -o jsonpath="$1" 2>/dev/null; }
check "has contexts team-a, prod-admin, staging-dev" eq "$(g '{.contexts[*].name}' | tr ' ' '\n' | grep -E '^(team-a|prod-admin|staging-dev)$' | sort | tr '\n' ' ')" "prod-admin staging-dev team-a "
check "has clusters k3s, prod, staging" eq "$(g '{.clusters[*].name}' | tr ' ' '\n' | sort | tr '\n' ' ')" "k3s prod staging "
check "current-context team-a"       eq "$(g '{.current-context}')" team-a
check "certs embedded (no file paths)" no grep -qE '^\s*(certificate-authority|client-certificate|client-key):' "$G"
check "merged file works against k3s" kubectl --kubeconfig="$G" get ns team-a
summary
