#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
C=backups.ckad.example.com; N="-n crd-25"
crd() { get crd $C -o jsonpath="$1"; }
try() { kubectl apply --dry-run=server -f - >/dev/null 2>&1 <<YAML
apiVersion: ckad.example.com/v1
kind: Backup
metadata: {name: probe, namespace: crd-25}
spec: $1
YAML
}
A=--as=system:serviceaccount:crd-25:backup-operator
echo "CRD"
check "exists"                       get crd $C
check "Namespaced, kind Backup, short name bk" eq "$(crd '{.spec.scope} {.spec.names.kind} {.spec.names.shortNames[*]}')" "Namespaced Backup bk"
check "v1 served+storage"            eq "$(crd '{.spec.versions[?(@.name=="v1")].served} {.spec.versions[?(@.name=="v1")].storage}')" "true true"
check "printer column Schedule"      has "$(crd '{.spec.versions[0].additionalPrinterColumns[*].name}')" Schedule
check "printer column Retention"     has "$(crd '{.spec.versions[0].additionalPrinterColumns[*].name}')" Retention
check "kubectl explain works"        has "$(kubectl explain backup.spec 2>/dev/null)" retention
echo "Validation"
check "valid backup accepted"        try '{schedule: "* * * * *", retention: 5}'
check "retention 100 rejected"       no try '{schedule: "* * * * *", retention: 100}'
check "retention 0 rejected"         no try '{schedule: "* * * * *", retention: 0}'
check "missing schedule rejected"    no try '{retention: 5}'
echo "Backup nightly"
check "exists (kubectl get bk)"      get bk nightly $N
check "spec 0 2 * * * / 7 / db"      eq "$(get bk nightly $N -o jsonpath='{.spec.schedule}/{.spec.retention}/{.spec.target}')" "0 2 * * */7/db"
echo "RBAC"
for v in get list watch create update patch delete; do check "operator can $v backups" can $v backups.ckad.example.com $N $A; done
check "operator cannot list pods"    no can list pods $N $A
check "operator cannot list backups in default" no can list backups.ckad.example.com -n default $A
summary
