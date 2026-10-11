# Canary deployment: run v2 alongside v1, split traffic via replica ratio

**Task:** `app-v1` (nginx:1.24, 4 replicas) is live behind service `app-svc`. Roll out a canary `app-v2` (nginx:1.25) that gets ~20% of traffic, verify it, then promote or roll back.

**Fastest route — same-labels trick (service selects both, ratio = replica ratio):**
```bash
k get deploy app-v1 -o jsonpath='{.spec.selector.matchLabels}'   # confirm shared label, e.g. app=app
```
Service must select only the shared label (not a version label):
```bash
k get svc app-svc -o jsonpath='{.spec.selector}'   # should be just {"app":"app"}, no "version" key
```
Deploy the canary with the shared `app=app` label on the pod template (Service selects this, not `version`):
```bash
k create deployment app-v2 --image=nginx:1.25 --replicas=1 $do > app-v2.yaml
```
Edit `app-v2.yaml` — ensure `spec.selector.matchLabels` and `spec.template.metadata.labels` both include `app: app` (plus `version: v2`). Then:
```bash
k apply -f app-v2.yaml
```
> `kubectl label deployment` only patches `metadata.labels` on the Deployment object, not `spec.template.metadata.labels`. Generate YAML and edit in place, or the Service won't select the pods.
Now traffic splits roughly by replica count: 4 (v1) : 1 (v2) ≈ 80/20.

**Verify:**
```bash
k get endpoints app-svc                     # lists pod IPs from BOTH deployments
for i in {1..10}; do curl -s app-svc | grep -o 'nginx/[0-9.]*'; done   # sample the split
```

**Promote (v2 becomes the only version):**
```bash
k scale deployment app-v2 --replicas=4
k delete deployment app-v1
```

**Roll back (kill the canary):**
```bash
k delete deployment app-v2
```

**Gotcha:** this is the "poor man's canary" — plain Kubernetes has no native weighted traffic split; it's purely proportional to replica count under one Service selector. Don't add Istio/Flagger/service-mesh machinery unless the task explicitly names it — CKAD tests the label/selector mechanics, not a mesh. The one thing that must be exactly right: the Service's `selector` must NOT include the `version` label, only the label both deployments share.
