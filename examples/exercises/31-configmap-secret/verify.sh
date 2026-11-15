#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
W="$(dirname "$0")/work"; N="-n config-31"
c()  { get pod app $N -o jsonpath="{.spec.containers[0].$1}"; }
ex() { kubectl exec app $N -- sh -c "$1" 2>/dev/null; }
echo "ConfigMap / Secret"
check "app-config APP_COLOR=blue"     eq "$(get cm app-config $N -o jsonpath='{.data.APP_COLOR}')" blue
check "app-config APP_MODE=staging (step 4)" eq "$(get cm app-config $N -o jsonpath='{.data.APP_MODE}')" staging
check "app-config has app.properties with debug" has "$(get cm app-config $N -o jsonpath='{.data.app\.properties}')" "log.level=debug"
check "db-creds type Opaque"          eq "$(get secret db-creds $N -o jsonpath='{.type}')" Opaque
check "db-creds DB_USER=admin"        eq "$(get secret db-creds $N -o jsonpath='{.data.DB_USER}' | base64 -d)" admin
echo "Pod app spec"
check "MODE from configMapKeyRef APP_MODE" eq "$(c 'env[?(@.name=="MODE")].valueFrom.configMapKeyRef.name')/$(c 'env[?(@.name=="MODE")].valueFrom.configMapKeyRef.key')" app-config/APP_MODE
check "FEATURE optional ref to feature-flags" eq "$(c 'env[?(@.name=="FEATURE")].valueFrom.configMapKeyRef.name')/$(c 'env[?(@.name=="FEATURE")].valueFrom.configMapKeyRef.optional')" feature-flags/true
check "envFrom secretRef db-creds"    eq "$(c 'envFrom[*].secretRef.name')" db-creds
check "config volume has only app.properties" eq "$(get pod app $N -o jsonpath='{.spec.volumes[?(@.configMap.name=="app-config")].configMap.items[*].key}')" app.properties
check "secret volume mode 0400 (256)" eq "$(get pod app $N -o jsonpath='{.spec.volumes[?(@.secret.secretName=="db-creds")].secret.defaultMode}')" 256
check "secret mounted readOnly at /etc/secret" eq "$(c 'volumeMounts[?(@.mountPath=="/etc/secret")].readOnly')" true
echo "Pod app runtime"
check "pod is Running"                eq "$(get pod app $N -o jsonpath='{.status.phase}')" Running
check "pod was not recreated (MODE still prod)" eq "$(ex 'echo $MODE')" prod
check "DB_PASSWORD env is s3cr3t"     eq "$(ex 'echo $DB_PASSWORD')" s3cr3t
check "mounted file updated to debug" has "$(ex 'cat /etc/config/app.properties')" "log.level=debug"
check "/etc/secret/DB_PASSWORD exists" ex 'test -f /etc/secret/DB_PASSWORD'
check "no APP_COLOR file in /etc/config" no ex 'test -e /etc/config/APP_COLOR'
echo "frozen / password"
check "frozen is immutable"           eq "$(get cm frozen $N -o jsonpath='{.immutable}/{.data.VERSION}')" true/1
check "frozen rejects changes"        no kubectl patch cm frozen $N --dry-run=server -p '{"data":{"VERSION":"2"}}'
check "work/password.txt = s3cr3t"    eq "$(tr -d '\n' < "$W/password.txt")" s3cr3t
summary
