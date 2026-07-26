# CRDs & Operators - CKAD Exam Tips

## Exam Shortcuts
- Name CRDs with DNS-label-compatible names: lowercase, no spaces, max 253 chars.
- `kubectl get <plural>` is the shortcut for custom resource lists.

## Pitfalls
1. **Wrong `kind` / `apiVersion`**: CRs must reference exact CRD `kind` and version.
2. **CRD Plural Mismatch**: Plural in `spec.names.plural` becomes cli noun.
3. **Validation not retroactive**: Adding SCC does not invalidate existing bad CRs.

## Time-Saver
```bash
alias k=kubectl

# Quick CRD check
k get crd | grep crontab
k get crontab
```
