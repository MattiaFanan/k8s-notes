# Multi-container pod with a sidecar sharing a volume

**Task:** Create pod `app-logs` with two containers: `app` (busybox, writes date to `/var/log/app.log` every 5s) and `sidecar` (busybox, tails that file). Share via an `emptyDir`.

**Fastest route:** generate a base pod, then hand-edit only the container list.
```bash
k run app-logs --image=busybox --restart=Never $do \
  -- /bin/sh -c 'while true; do date >> /var/log/app.log; sleep 5; done' > pod.yaml
```
Edit `pod.yaml` to add the sidecar container and the shared volume:
```yaml
spec:
  volumes:
  - name: logs
    emptyDir: {}
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh","-c","while true; do date >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: sidecar
    image: busybox
    command: ["/bin/sh","-c","tail -f /var/log/app.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
```
```bash
k apply -f pod.yaml
```

**Verify:**
```bash
k logs app-logs -c sidecar -f
```

**Gotcha:** `emptyDir` is node-local and ephemeral — correct default for "share files between containers in same pod." Don't reach for a PVC unless persistence across pod restarts is asked.
