# Expose an app via ClusterIP and NodePort

**Task:** Deployment `api` (3 replicas, port 8080) needs a ClusterIP service `api-internal` and a NodePort service `api-external` on nodePort 30080.

**Fastest route:**
```bash
k create deployment api --image=myapp:1.0 --replicas=3 --port=8080
k expose deployment api --name=api-internal --port=80 --target-port=8080
k expose deployment api --name=api-external --port=80 --target-port=8080 --type=NodePort
k patch svc api-external -p '{"spec":{"ports":[{"port":80,"targetPort":8080,"nodePort":30080}]}}'
```

**Verify:**
```bash
k get svc api-internal api-external
k get svc api-external -o jsonpath='{.spec.ports[0].nodePort}'
```

**Gotcha:** `kubectl expose` can't set an explicit `nodePort` value directly — either patch after, or generate with `$do` and edit the YAML before apply. Valid NodePort range is 30000-32767; picking outside that fails validation.
