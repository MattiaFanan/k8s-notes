# 25 – Solution

```bash
kubectl apply -f crd.yaml
kubectl get crd backups.ckad.example.com
kubectl api-resources --api-group=ckad.example.com     # backups  bk  ckad.example.com/v1  true  Backup
kubectl explain backup.spec
kubectl apply -f resources.yaml
kubectl get bk -n crd-25                                # NAME SCHEDULE RETENTION AGE
echo '{"apiVersion":"ckad.example.com/v1","kind":"Backup","metadata":{"name":"x","namespace":"crd-25"},"spec":{"schedule":"x","retention":100}}' \
  | kubectl apply -f -      # spec.retention: Invalid value: 100: spec.retention in body should be less than or equal to 30
kubectl create role backup-editor -n crd-25 --verb='*' --resource=backups.ckad.example.com   # imperative alternative
```

## Key points
- A CRD adds a new **resource type** to the API: after that, `kubectl get/apply/delete/explain` and RBAC work for it like for
  built-in types. The name must be `<plural>.<group>`.
- `openAPIV3Schema` is required in `apiextensions.k8s.io/v1`. Unknown fields are **pruned** (dropped silently) unless
  `x-kubernetes-preserve-unknown-fields: true`. `kubectl apply` warns about them.
- Validation (`required`, `minimum`, `enum`, `pattern`, CEL rules in `x-kubernetes-validations`) runs on the API server.
- RBAC for custom resources: `apiGroups: [<crd group>]`, `resources: [<plural>]`.
- Deleting the CRD deletes **all** its custom resources.

## Answer
A CRD on its own only stores data. An **operator** = CRD + a **controller** (usually a Deployment) that watches those objects and
makes the cluster match them (here, it would create CronJobs that run the backups). Cert-manager, Prometheus operator and
database operators all work this way. In the exam you mostly use operators that are already installed: list their CRDs and create or inspect CRs.
