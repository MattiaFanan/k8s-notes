# CRDs & Operators - CKAD Exam Tips

> **CKAD Exam Version**: Kubernetes v1.35

## See also

- [CRD YAML Structure](./../1-yaml-structure.md)
- [CRD Deep Dive](./../2-mechanics/01-custom-resource-definition-crd.md)
- [Custom Resources](./../2-mechanics/02-custom-resources-crs.md)
- [Operators](./../2-mechanics/03-operators.md)
- [CRD/CR/Operator Relationship](./../2-mechanics/04-relationship.md)

## Exam Shortcuts

- Name CRDs with DNS-label-compatible names: lowercase, no spaces, max 253 chars.
- `kubectl get <plural>` is the shortcut for custom resource lists.
- Use `kubectl explain <kind>` after applying a CRD to inspect available fields.

## Pitfalls

1. **Wrong `kind` / `apiVersion`**: CRs must reference exact CRD `kind` and version.
2. **CRD Plural Mismatch**: Plural in `spec.names.plural` becomes cli noun.
3. **Validation is retroactive for structural schemas**: Adding or updating `openAPIV3Schema` constraints **does** validate existing CRs against the new schema in Kubernetes v1.16+ (including v1.35). Existing CRs that fail validation will be rejected on update. For non-structural schemas, behavior may differ.
4. **Only one `storage: true` version**: Set by the CRD author, not by end users.

## Time-Saver

```bash
alias k=kubectl

# Quick CRD check
k get crd | grep crontab
k get crontab

# Inspect CRD fields after applying
k explain crontab
```

## Additional Tips

- A CRD defines the schema (`openAPIV3Schema`) that custom resources must conform to.
- Only one version may have `storage: true`. This is set by the CRD author (operator developer), not by end users.
- Create custom resources with `kubectl apply -f <cr>.yaml` using the `apiVersion` format `<group>/<version>`.
- Use `kubectl get <crd-name>` to list CRs, and `kubectl describe <crd-name> <name>` for details.
