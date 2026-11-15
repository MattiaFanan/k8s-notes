#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N=sa-07
SATOK=/var/run/secrets/kubernetes.io/serviceaccount/token
jwt() { local p; p=$(cut -d. -f2 | tr '_-' '/+'); while [ $(( ${#p} % 4 )) -ne 0 ]; do p="$p="; done; base64 -d <<<"$p" 2>/dev/null; }
sa() { get pod "$1" -n $N -o jsonpath='{.spec.serviceAccountName}'; }
echo "ServiceAccount builder"
check "exists"                       get sa builder -n $N
check "automountServiceAccountToken false" eq "$(get sa builder -n $N -o jsonpath='{.automountServiceAccountToken}')" false
echo "Pod no-token"
check "uses builder"                 eq "$(sa no-token)" builder
check "Running"                      eq "$(get pod no-token -n $N -o jsonpath='{.status.phase}')" Running
check "no token mounted"             kubectl exec -n $N no-token -- sh -c "! test -e $SATOK"
echo "Pod with-token"
check "uses builder"                 eq "$(sa with-token)" builder
check "pod-level automount true"     eq "$(get pod with-token -n $N -o jsonpath='{.spec.automountServiceAccountToken}')" true
check "token mounted"                kubectl exec -n $N with-token -- test -s $SATOK
echo "Pod vault-client"
check "uses builder"                 eq "$(sa vault-client)" builder
P=$(kubectl exec -n $N vault-client -- cat /var/run/secrets/tokens/vault-token 2>/dev/null | jwt)
check "token file present"           has "$P" '"aud"'
check "audience vault"               eq "$(jq -r '.aud[0]' <<<"$P" 2>/dev/null)" vault
check "lifetime 3600s"               eq "$(jq -r '.exp - .iat' <<<"$P" 2>/dev/null)" 3600
check "subject is builder"           eq "$(jq -r '.sub' <<<"$P" 2>/dev/null)" system:serviceaccount:sa-07:builder
echo "Secret builder-token"
check "type service-account-token"   eq "$(get secret builder-token -n $N -o jsonpath='{.type}')" kubernetes.io/service-account-token
check "bound to builder"             eq "$(get secret builder-token -n $N -o jsonpath='{.metadata.annotations.kubernetes\.io/service-account\.name}')" builder
check "data.token populated"         test -n "$(get secret builder-token -n $N -o jsonpath='{.data.token}')"
summary
