#!/usr/bin/env bash
source "$(dirname "$0")/../../lib.sh"
N="-n multi-24"
p() { get pod web $N -o jsonpath="$1"; }
echo "Pod web"
check "init container fetch"          has "$(p '{.spec.initContainers[*].name}')" fetch
check "log-shipper is a native sidecar" eq "$(p '{.spec.initContainers[?(@.name=="log-shipper")].restartPolicy}')" Always
check "2/2 containers ready"          eq "$(p '{.status.containerStatuses[?(@.ready==true)].name}') $(p '{.status.initContainerStatuses[?(@.name=="log-shipper")].ready}')" "nginx true"
check "serves 'hello from init'"      eq "$(kubectl exec $N web -c nginx -- wget -qO- 127.0.0.1 2>/dev/null)" "hello from init"
sleep 2
check "log-shipper shows the GET"     has "$(kubectl logs $N web -c log-shipper 2>/dev/null)" "GET / HTTP"
echo "Pod waiter"
check "has init container wait-for-backend" has "$(get pod waiter $N -o jsonpath='{.spec.initContainers[*].name}')" wait-for-backend
check "service backend exists"        get svc backend $N
check "waiter Running"                eq "$(get pod waiter $N -o jsonpath='{.status.phase}')" Running
echo "Job batch"
check "helper is a native sidecar"    eq "$(get job batch $N -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="helper")].restartPolicy}')" Always
check "Job Complete"                  eq "$(get job batch $N -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')" True
check "work printed finished"         has "$(kubectl logs $N job/batch -c work 2>/dev/null)" finished
summary
