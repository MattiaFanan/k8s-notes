apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  request: ${CSR_B64}                         # base64 of jane.csr, single line
  signerName: kubernetes.io/kube-apiserver-client
  usages: [client auth]
  expirationSeconds: 86400
