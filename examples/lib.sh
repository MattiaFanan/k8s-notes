# Sourced by every setup/verify/teardown/solve script.
PASS=0; FAIL=0
check() { local d=$1; shift; if "$@" >/dev/null 2>&1; then echo "  [PASS] $d"; PASS=$((PASS+1)); else echo "  [FAIL] $d"; FAIL=$((FAIL+1)); fi; }
eq()  { [ "$1" = "$2" ]; }
has() { grep -q -- "$2" <<<"$1"; }          # has "<text>" "<substring>"
no()  { ! "$@"; }
get() { kubectl get "$@" 2>/dev/null; }
can() { [ "$(kubectl auth can-i "$@" 2>/dev/null)" = yes ]; }
ns()  { kubectl create ns "$1" --dry-run=client -o yaml | kubectl apply -f - >/dev/null; }
# curl through traefik (k3s LoadBalancer on localhost)
http() { curl -s -m 5 -H "Host: $1" "http://127.0.0.1$2"; }
summary() { echo; echo "Result: $PASS passed, $FAIL failed"; [ "$FAIL" -eq 0 ]; }
# echo backend: deployment+service answering "<text>" (used by ingress setups)
echo_app() { # echo_app <ns> <name> <svc-port> [selector-override]
  kubectl create deploy "$2" -n "$1" --image=hashicorp/http-echo:1.0 --dry-run=client -o yaml -- /http-echo -text="$2" -listen=:5678 | kubectl apply -f - >/dev/null
  kubectl apply -f - >/dev/null <<YAML
apiVersion: v1
kind: Service
metadata: {name: ${5:-$2}, namespace: $1}
spec:
  selector: {app: ${4:-$2}}
  ports: [{name: http, port: $3, targetPort: 5678}]
YAML
}
# reach <url> from inside pod <ns>/<pod> (busybox wget, 3s timeout)
reach() { kubectl exec -n "$1" "$2" -- wget -qO- -T 3 "$3" >/dev/null 2>&1; }
# sorted pod IPs behind a Service / matching a selector
svc_ips() { kubectl get endpointslices -n "$1" -l kubernetes.io/service-name="$2" -o jsonpath='{range .items[*].endpoints[?(@.conditions.ready==true)]}{.addresses[0]}{"\n"}{end}' 2>/dev/null | sort | tr '\n' ' '; }
pod_ips() { kubectl get pods -n "$1" -l "$2" --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}' 2>/dev/null | sort | tr '\n' ' '; }
