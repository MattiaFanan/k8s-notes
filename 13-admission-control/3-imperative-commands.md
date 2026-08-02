# Admission Control, Authentication & Authorization - Imperative Commands

## ServiceAccounts

```bash
# Create ServiceAccount
kubectl create serviceaccount my-sa -n default

# Get SA token (K8s 1.24+)
kubectl create token my-sa -n default
```

## ImagePullSecrets

```bash
# Create Docker registry secret
kubectl create secret docker-registry my-registry-cred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=user \
  --docker-password=pass

# Patch ServiceAccount default with imagePullSecret
kubectl patch sa default -p '{"imagePullSecrets": [{"name": "my-registry-cred"}]}'
```

## Admission Webhooks

```bash
# List Validating/Mutating Webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Describe webhook
kubectl describe validatingwebhookconfiguration object-validator
```

## Audit & Debug
```bash
kubectl get events -n default
kubectl logs -l app=webhook --all-containers -n default
```

## Delete
```bash
kubectl delete validatingwebhookconfiguration object-validator
kubectl delete mutatingwebhookconfiguration pod-mutator
```
