# Consume a ConfigMap as env vars and as a mounted file

**Task:** Create ConfigMap `app-config` with `LOG_LEVEL=debug` and a file `app.properties` containing `retries=3`. Mount the file into a pod, and inject `LOG_LEVEL` as an env var.

**Fastest route:**
```bash
k create configmap app-config \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=app.properties='retries=3'
# or for a real file: --from-file=app.properties=./app.properties

k run cfg-pod --image=nginx $do > pod.yaml
```
Edit `pod.yaml`:
```yaml
    envFrom:
    - configMapRef:
        name: app-config          # pulls ALL keys as env (skip if only one var needed)
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: LOG_LEVEL
    volumeMounts:
    - name: cfg-vol
      mountPath: /etc/config
```
Add at pod spec level:
```yaml
  volumes:
  - name: cfg-vol
    configMap:
      name: app-config
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k exec cfg-pod -- env | grep LOG_LEVEL
k exec cfg-pod -- cat /etc/config/app.properties
```

**Gotcha:** don't mix `--from-literal=app.properties=...` (a fake "file") with real multi-line file content in the exam unless asked — if a real file is given, use `--from-file` so the key is the filename.
