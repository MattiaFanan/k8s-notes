# 07 – ServiceAccounts and tokens

Run `./setup.sh` first. Namespace: `sa-07`. Use image `busybox:1.36` with `sleep 3600` for all pods.

1. Create a ServiceAccount `builder` that does **not** automount its API token.
2. Create a Pod `no-token` that uses `builder`. Check that `/var/run/secrets/kubernetes.io/serviceaccount` does not exist in it.
3. Create a Pod `with-token` that also uses `builder`, but overrides this **at pod level** so the token is mounted.
4. Create a Pod `vault-client` that uses `builder` and gets a **projected** ServiceAccount token:
   - audience `vault`, expiration `3600` seconds
   - file `/var/run/secrets/tokens/vault-token`
5. Create a long-lived token Secret `builder-token` for `builder` (the pre-1.24 style). Make sure the
   token controller has filled in `data.token`.
6. Print a short-lived token for `builder` valid for 10 minutes (no object is created). Which command did you use?
7. Question: which ServiceAccount does a pod use when `serviceAccountName` is not set?

Check with `./verify.sh`(you'll need jq installed), clean up with `./teardown.sh`.
