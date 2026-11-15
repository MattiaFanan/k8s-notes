# 09 – Solution

`solve.sh` does all of this. Step by step, inside `exercises/09-user-csr/work/`:

```bash
# 1. key + certificate request. CN = username, O = group (repeat /O=... for more groups)
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -subj "/CN=jane/O=dev-team" -out jane.csr

# 2. CSR object. spec.request = base64 of the PEM CSR on ONE line
cat <<YAML | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata: {name: jane}
spec:
  request: $(base64 -w0 jane.csr)
  signerName: kubernetes.io/kube-apiserver-client
  usages: [client auth]
  expirationSeconds: 86400
YAML
kubectl get csr                       # Pending
kubectl certificate approve jane      # (deny: kubectl certificate deny jane)
kubectl get csr jane -o jsonpath='{.status.certificate}' | base64 -d > jane.crt
openssl x509 -in jane.crt -noout -subject -enddate

# 3. a NEW kubeconfig file: every command gets --kubeconfig, so ~/.kube/k3s.yaml is never written
kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > ca.crt
K=--kubeconfig=jane.kubeconfig
kubectl config $K set-cluster k3s --server=https://127.0.0.1:6443 --certificate-authority=ca.crt --embed-certs=true
kubectl config $K set-credentials jane --client-certificate=jane.crt --client-key=jane.key --embed-certs=true
kubectl config $K set-context jane@k3s --cluster=k3s --user=jane --namespace=users-09
kubectl config $K use-context jane@k3s

# 4. RBAC, as admin
kubectl create role deployer -n users-09 --verb=get,list,watch,create,update,patch,delete --resource=deployments.apps
kubectl edit role deployer -n users-09        # add the second rule for pods (get,list,watch), or apply rbac.yaml
kubectl create rolebinding deployer-dev-team -n users-09 --role=deployer --group=dev-team

# 5. + 6. as jane
kubectl $K auth whoami                                  # Username jane, Groups [dev-team system:authenticated]
kubectl $K create deployment jane-app --image=nginx:1.27-alpine
kubectl $K auth can-i get secrets                       # no
kubectl $K auth can-i create deployments -n default     # no
```
As admin you can also impersonate jane: `kubectl auth can-i create deploy -n users-09 --as=jane --as-group=dev-team`.

## Key points
- `kubernetes.io/kube-apiserver-client` is the signer for client certificates that the API server trusts.
  Usage must be `client auth`. On k3s the controller-manager signs with the cluster client CA.
- Approving is a separate step. The certificate shows up in `.status.certificate` (base64 PEM).
- `--embed-certs=true` copies the file contents into `*-data` fields, so the kubeconfig is self-contained.
  Without it the kubeconfig stores file **paths**.
- Binding to a **Group** (`--group`) instead of a User (`--user`) means everyone whose cert has `O=dev-team` gets the role.
  Group membership comes from the certificate only. Kubernetes keeps no group list.
- A client certificate cannot be revoked. Only expiry (or removing the RBAC binding) stops it, so keep `expirationSeconds` short.
- Use the file with `kubectl --kubeconfig work/jane.kubeconfig ...` or `KUBECONFIG=$PWD/work/jane.kubeconfig kubectl ...`.
