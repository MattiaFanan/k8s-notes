# 09 – Create a user with a CertificateSigningRequest and give them a kubeconfig

Run `./setup.sh` first. Namespace: `users-09`. Work in `exercises/09-user-csr/work/` (created by setup).

Kubernetes has no User objects. A "user" is whoever presents a certificate signed by the cluster CA:
`CN` = username, `O` = groups.

1. In `work/`, create a private key `jane.key` and a CSR `jane.csr` for **CN=jane, O=dev-team**.
2. Create a CertificateSigningRequest object `jane`: signer `kubernetes.io/kube-apiserver-client`,
   usage `client auth`, valid for 1 day (`expirationSeconds: 86400`). Approve it and save the
   signed certificate to `work/jane.crt`.
3. Create a **new** kubeconfig file `work/jane.kubeconfig` (do **not** touch `~/.kube/k3s.yaml`) with:
   - cluster `k3s`: same server and CA as in `~/.kube/k3s.yaml`, CA **embedded**
   - user `jane`: client cert and key **embedded**
   - context `jane@k3s` = cluster `k3s` + user `jane` + namespace `users-09`, set as current context
4. Create a Role `deployer` in `users-09` (deployments: get list watch create update patch delete;
   pods: get list watch) and a RoleBinding `deployer-dev-team` that grants it to the **group** `dev-team`.
5. **Using `work/jane.kubeconfig`**, create a Deployment `jane-app` (`nginx:1.27-alpine`) in `users-09`.
6. Check with `kubectl --kubeconfig work/jane.kubeconfig auth whoami` and `auth can-i`.
   jane must not be able to read secrets, or create deployments in `default`.

Check with `./verify.sh`, clean up with `./teardown.sh`.
