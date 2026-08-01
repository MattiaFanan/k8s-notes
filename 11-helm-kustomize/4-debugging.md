# Helm & Kustomize - Debugging

## Helm Issues

1. **Release Install Failure**
   ```bash
   helm lint ./mychart
   helm install test ./mychart --debug --dry-run
   ```
   *Root Cause*: Template syntax error, chart version mismatch, or invalid values.

2. **Upgrade Failure**
   ```bash
   helm history my-release
   helm rollback my-release <revision>
   ```
   *Root Cause*: Release partially deployed or hooks failing.

3. **Values Not Applied**
   - Verify override precedence: CLI `--set` > `-f` values file > `values.yaml`.
   - Check `helm get values my-release`.

## Kustomize Issues

1. **Base Resource Conflicts**
   - Overlay edits applied to wrong resource if `namePrefix` / `namespace` mismatches.
2. **Rendered Manifest Issues**
   - `kubectl kustomize` to see final output before applying.

## General
- If helm/kustomize not allowed on exam, revert to raw YAML templates.
