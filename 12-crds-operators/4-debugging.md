# CRDs & Operators - Debugging

## Common Issues

1. **CRD Not Showing Under `kubectl get`**
   - Verify `spec.names.plural` matches your `kubectl get` noun.
   - Example: `CronTab` CRD uses plural `crontabs`, so use `kubectl get crontabs`.

2. **No CRD Instances**
   ```bash
   kubectl get crd
   kubectl get crontab
   ```
   *Root Cause*: CRD exists but no CR instances created yet.

3. **Validation Fails**
   ```bash
   kubectl describe crd crontabs.stable.example.com
   ```
   - Check if `openAPIV3Schema` enforces required fields or types.

4. **CR Not Accepted**
   *Root Cause*: API version mismatch, kind mismatch, or missing required spec fields.

## Additional Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| CRD not appearing in `kubectl get crds` | API server extension server not ready | Wait a few seconds; check API server health |
| `schema is empty` | CRD created without `openAPIV3Schema` | Add validation schema to CRD definition |
| Custom resource rejected | Does not match CRD schema | Validate YAML against `openAPIV3Schema` |
| `stored object is too large` | Resource exceeds `maxRequestBytes` | Reduce resource size or adjust API server limit |
| `no matches for kind` | CRD not applied or not established | Verify CRD exists: `kubectl get crd <name>` |
