# StatefulSet with a headless service for stable network identity

**Task:** Create StatefulSet `web` (3 replicas, `nginx`) backed by headless service `web-headless`, each pod addressable as `web-0.web-headless...`.

**Fastest route:** no imperative `create statefulset` — headless service + short YAML.
```bash
k create service clusterip web-headless --tcp=80:80 --clusterip=None
```
`sts.yaml`:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: web-headless
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```
```bash
k apply -f sts.yaml
```

**Verify:**
```bash
k get pods -l app=web    # names: web-0, web-1, web-2 (ordinal, stable)
k run dns-test --image=busybox --rm -it --restart=Never -- \
  nslookup web-0.web-headless
```

**Gotcha:** the service's label `selector` must match the StatefulSet pod template's labels, and `spec.serviceName` in the StatefulSet must match the headless service's `metadata.name` exactly — this link is what gives pods their stable DNS.
