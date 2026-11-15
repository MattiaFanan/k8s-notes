#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; F="$W/jane.kubeconfig"
J() { kubectl --kubeconfig "$F" "$@" 2>/dev/null; }
cfg() { J config view --raw -o jsonpath="$1"; }
echo "Original kubeconfig"
check "~/.kube/k3s.yaml unchanged"   eq "$(sha256sum "$KUBECONFIG" | cut -d' ' -f1)" "$(cat "$W/.k3s.sha" 2>/dev/null)"
echo "Key / CSR / certificate"
check "work/jane.key exists"         test -s "$W/jane.key"
check "CSR jane signer kube-apiserver-client" eq "$(get csr jane -o jsonpath='{.spec.signerName}')" kubernetes.io/kube-apiserver-client
check "CSR usage client auth"        eq "$(get csr jane -o jsonpath='{.spec.usages[*]}')" "client auth"
check "CSR expirationSeconds 86400"  eq "$(get csr jane -o jsonpath='{.spec.expirationSeconds}')" 86400
check "CSR approved"                 eq "$(get csr jane -o jsonpath='{.status.conditions[?(@.type=="Approved")].status}')" True
SUBJ=$(openssl x509 -in "$W/jane.crt" -noout -subject -nameopt RFC2253 2>/dev/null)
check "work/jane.crt CN=jane"        has "$SUBJ" "CN=jane"
check "work/jane.crt O=dev-team"     has "$SUBJ" "O=dev-team"
echo "work/jane.kubeconfig"
check "current-context jane@k3s"     eq "$(cfg '{.current-context}')" jane@k3s
check "context: cluster k3s, user jane, ns users-09" eq "$(cfg '{.contexts[?(@.name=="jane@k3s")].context.cluster}/{.contexts[?(@.name=="jane@k3s")].context.user}/{.contexts[?(@.name=="jane@k3s")].context.namespace}')" k3s/jane/users-09
check "cluster k3s CA embedded"      test -n "$(cfg '{.clusters[?(@.name=="k3s")].cluster.certificate-authority-data}')"
check "user jane cert+key embedded"  test -n "$(cfg '{.users[?(@.name=="jane")].user.client-certificate-data}')" -a -n "$(cfg '{.users[?(@.name=="jane")].user.client-key-data}')"
check "authenticates as jane"        eq "$(J auth whoami -o jsonpath='{.status.userInfo.username}')" jane
check "member of group dev-team"     has "$(J auth whoami -o jsonpath='{.status.userInfo.groups[*]}')" dev-team
echo "RBAC"
check "RoleBinding subject is Group dev-team" eq "$(get rolebinding deployer-dev-team -n users-09 -o jsonpath='{.subjects[0].kind}/{.subjects[0].name}')" Group/dev-team
check "RoleBinding -> Role deployer"  eq "$(get rolebinding deployer-dev-team -n users-09 -o jsonpath='{.roleRef.kind}/{.roleRef.name}')" Role/deployer
check "jane can create deployments in users-09" eq "$(J auth can-i create deployments)" yes
check "jane can delete deployments in users-09" eq "$(J auth can-i delete deployments)" yes
check "jane cannot delete pods"      eq "$(J auth can-i delete pods)" no
check "jane cannot get secrets"      eq "$(J auth can-i get secrets)" no
check "jane cannot create deployments in default" eq "$(J auth can-i create deployments -n default)" no
check "deployment jane-app exists"   eq "$(get deploy jane-app -n users-09 -o jsonpath='{.spec.template.spec.containers[0].image}')" nginx:1.27-alpine
summary
