# 24 – Multi-container pods: init containers and native sidecars

Run `./setup.sh` first. Namespace: `multi-24`.

1. Pod `web`:
   - **init container** `fetch` (`busybox:1.36`) writes `hello from init` to `index.html` in an `emptyDir` volume `html`
   - main container `nginx` (`nginx:1.27-alpine`) serves `html` as `/usr/share/nginx/html`
   - **native sidecar** `log-shipper` (`busybox:1.36`, runs `tail -F /logs/access.log`): an init container with
     `restartPolicy: Always`. It shares an `emptyDir` `logs` that nginx mounts at `/var/log/nginx`.
   After a request (`kubectl exec -n multi-24 web -c nginx -- wget -qO- 127.0.0.1`), the request line must show up in
   `kubectl logs -n multi-24 web -c log-shipper`.
2. Pod `waiter`: init container `wait-for-backend` loops until the DNS name `backend.multi-24.svc.cluster.local`
   resolves, then the main container (`busybox:1.36`, `sleep 3600`) starts. Create the pod first and watch it stay in
   `Init:0/1`. Then make it start (without changing the pod).
3. Job `batch`: the main container `work` runs `sh -c 'echo working; sleep 5; echo finished'`. It has a native sidecar
   `helper` that runs `sleep 3600`. The Job must reach **Complete**, even though the sidecar never exits.
4. Question: why would a normal (non-native) sidecar container block the Job?

Check with `./verify.sh`, clean up with `./teardown.sh`.
