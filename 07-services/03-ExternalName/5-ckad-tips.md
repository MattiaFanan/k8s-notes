# Services - ExternalName - CKAD Exam Tips

## Shortcuts
- `kubectl create service externalname` scaffolding is fast.
- DNS test with `nslookup` confirms mapping.

## Pitfalls
1. **No selector/ports**: Adding these will cause validation errors.
2. **Network restrictions**: External host must allow traffic from cluster CIDR.
3. **No cluster IP**: If `clusterIP` specified, it is ignored.

## Time-Saver
```bash
alias k=kubectl
k create service externalname mydb --external-name=mydb.example.com
```
