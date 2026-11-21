# 08 – A ServiceAccount that calls the API from a pod

Run `./setup.sh` first. Namespaces: `sa-08` and `sa-08-other` (it contains a Service `backend`).

1. Create a ServiceAccount `pod-reader` in `sa-08`.
2. Create a Role `read-pods` in `sa-08` that allows `get`, `list`, `watch` on pods and `get` on `pods/log`.
   Bind it to `pod-reader` with a RoleBinding `read-pods`.
3. Give `pod-reader` **read-only access to everything in `sa-08-other`** by reusing the built-in ClusterRole `view`
   (RoleBinding `view-other` in `sa-08-other`). It must **not** get any cluster-wide permission.
4. Create a Pod `api-client` in `sa-08` (image `curlimages/curl:8.10.1`) that runs as `pod-reader` and,
   every 10 seconds, lists the pods of `sa-08` through the API server, **using the mounted token and CA**:
   `https://kubernetes.default.svc/api/v1/namespaces/sa-08/pods`.
   The response must be in the pod logs.

   You can see the token mount path from the pod once started.
   ```bash
   command:
      - "/bin/sh"
      - "-c"
      - 'while true; do sleep 10; curl -s --cacert TOKEN_MOUNT_PATH/ca.crt -X GET "https://kubernetes.default.svc/api/v1/namespaces/sa-08/pods" -H "Authorization: Bearer $(cat TOKEN_MOUNT_PATH/token)"; done'
   ```
   - -s to reduce info returned
   - --cacert (or -k) is needed to make curl trust the connection
   - -H sets the serviceaccount token to avoid the 403 unauthorized

5. Check with `kubectl auth can-i ... --as=system:serviceaccount:sa-08:pod-reader`:
   - can list pods in sa-08, cannot delete them
   - cannot list secrets in sa-08
   - can list services in sa-08-other, cannot list services in sa-08

Check with `./verify.sh`, clean up with `./teardown.sh`.
