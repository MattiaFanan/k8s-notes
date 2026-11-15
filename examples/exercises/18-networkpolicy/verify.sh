#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
U() { echo "http://$1.np-18.svc.cluster.local"; }
echo "Policies exist"
for p in default-deny allow-dns web-ingress api-ingress db-ingress frontend-egress api-egress; do check "$p" get netpol $p -n np-18; done
check "default-deny covers Ingress and Egress" eq "$(get netpol default-deny -n np-18 -o jsonpath='{.spec.policyTypes[*]}')" "Ingress Egress"
echo "Connectivity"
check "frontend -> web ok"             reach np-18 frontend "$(U web)"
check "frontend -> api ok"             reach np-18 frontend "$(U api)"
check "frontend -> db blocked"         no reach np-18 frontend "$(U db)"
check "frontend -> internet blocked"   no reach np-18 frontend http://1.1.1.1
check "intruder -> web blocked"        no reach np-18 intruder "$(U web)"
check "intruder -> api blocked"        no reach np-18 intruder "$(U api)"
check "monitor/prober -> api ok"       reach np-18-monitor prober "$(U api)"
check "monitor/prober -> web blocked"  no reach np-18-monitor prober "$(U web)"
check "monitor/prober -> db blocked"   no reach np-18-monitor prober "$(U db)"
check "other/prober -> api blocked"    no reach np-18-other prober "$(U api)"
kubectl run api-probe -n np-18 --image=busybox:1.36 -l app=api --restart=Never -- sleep 300 >/dev/null 2>&1; kubectl wait -n np-18 pod/api-probe --for=condition=Ready --timeout=60s >/dev/null 2>&1
check "pod labelled app=api -> db ok" reach np-18 api-probe "$(U db)"
check "pod labelled app=api -> web blocked" no reach np-18 api-probe "$(U web)"
kubectl delete pod api-probe -n np-18 --now >/dev/null 2>&1
summary
