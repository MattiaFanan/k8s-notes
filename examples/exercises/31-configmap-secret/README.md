# 31 – ConfigMaps and Secrets

Run `./setup.sh` first. Namespace: `config-31`. Setup writes `work/app.properties`.

1. ConfigMap `app-config` with literals `APP_MODE=prod`, `APP_COLOR=blue`, and the file `work/app.properties`
   (key `app.properties`). Use `kubectl create`, not YAML.
2. Secret `db-creds` (generic) with `DB_USER=admin`, `DB_PASSWORD=s3cr3t`.
3. Pod `app` (`busybox:1.36`, `sleep 3600`):
   - env `MODE` from key `APP_MODE` of `app-config`
   - env `FEATURE` from key `NEW_UI` of ConfigMap `feature-flags` (it does **not** exist; the pod must still start)
   - **all** keys of `db-creds` as env vars (`envFrom`)
   - only the key `app.properties` of `app-config` mounted as file `/etc/config/app.properties`
   - `db-creds` mounted read-only at `/etc/secret`, file mode `0400`
4. Without touching the pod, change the ConfigMap: `log.level=debug` in `app.properties`, and `APP_MODE=staging`.
   Wait ~1 min. What changed inside the pod (`cat /etc/config/app.properties`, `echo $MODE`)? **Don't recreate the pod.**
5. ConfigMap `frozen` with `VERSION=1` that can never be changed. Try `kubectl edit`.
6. Read the password back from the Secret with `kubectl get ... -o jsonpath` and write it (plain text) to `work/password.txt`.
7. Question: would step 4 update the file if it was mounted with `subPath: app.properties`?

Check with `./verify.sh` (after step 6), clean up with `./teardown.sh`.
