# Create a Secret and consume it as env var + mounted volume

**Task:** Create a generic secret `db-creds` with `username=admin` and `password=S3cr3t`. Inject `password` as env var `DB_PASSWORD` in a pod, and mount the whole secret at `/etc/secret`.

**Fastest route:**
```bash
k create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=S3cr3t

k run secret-pod --image=nginx $do > pod.yaml
```
Edit `pod.yaml`:
```yaml
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-creds
          key: password
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secret
      readOnly: true
```
pod spec level:
```yaml
  volumes:
  - name: secret-vol
    secret:
      secretName: db-creds
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k exec secret-pod -- printenv DB_PASSWORD
k exec secret-pod -- ls /etc/secret
```

**Gotcha:** secret values are base64 in `kubectl get secret -o yaml`, NOT encrypted — `--from-literal` handles encoding for you, never manually base64 unless building raw YAML with `data:` (use `stringData:` instead to skip encoding by hand).
