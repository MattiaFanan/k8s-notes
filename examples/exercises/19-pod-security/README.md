# 19 – securityContext and Pod Security Admission

Run `./setup.sh` first. Namespace: `psa-19`. Setup also writes `work/bad-pod.yaml`.

1. Make namespace `psa-19` **enforce** the Pod Security Standard `restricted` (version `latest`) and also **warn** on it.
2. Try `kubectl apply -f work/bad-pod.yaml`. It must be rejected. Read the error: which fields does it list?
3. Create Pod `secure` with image `nginxinc/nginx-unprivileged:1.27-alpine` (listens on 8080) that runs in `psa-19`:
   - runs as non-root, user `101`
   - no privilege escalation, all capabilities dropped, seccomp profile `RuntimeDefault`
   - **read-only root filesystem**. nginx needs to write to `/tmp`, so give it a writable `emptyDir` there.
   It must serve: `kubectl exec -n psa-19 secure -- wget -qO- 127.0.0.1:8080` returns the nginx page.
4. Create Pod `ids` (`busybox:1.36`, `sleep 3600`) that runs with **user 1000, group 3000, supplementary
   group (fsGroup) 2000**, set at **pod** level, and mounts an `emptyDir` at `/data`. It must also pass `restricted`.
   Open a shell into pod `ids` to check the result of commands `id` and `ls -ld /data` in it. 
   Which group owns `/data`?

Check with `./verify.sh`, clean up with `./teardown.sh`.
