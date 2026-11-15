# 16 – Kustomize: one base, two environments

Run `./setup.sh` first. It creates namespaces `kust-dev`, `kust-prod` and an empty `work/` directory.
Build this layout in `exercises/16-kustomize-overlays/work/`:

```
work/
├── base/              deployment.yaml, service.yaml, kustomization.yaml
└── overlays/
    ├── dev/           kustomization.yaml
    └── prod/          kustomization.yaml, app.properties
```

**base**
- Deployment `web` (label `app=web`, 1 replica, `nginx:1.27-alpine`) that loads all keys of ConfigMap
  `web-config` as environment variables (`envFrom`)
- Service `web`, port 80 -> 80, selector `app=web`
- `web-config` is **generated** by kustomize: `APP_ENV=base`, `LOG_LEVEL=info`

**overlays/dev**
- namespace `kust-dev`, name prefix `dev-`, label `env=dev` on all objects **and** selectors
- `web-config` merged with `APP_ENV=dev`, `LOG_LEVEL=debug`

**overlays/prod**
- namespace `kust-prod`, name prefix `prod-`, label `env=prod` on all objects and selectors
- 3 replicas (`replicas:` field), image `nginx` with tag `1.27` (`images:` field)
- `web-config` merged with `APP_ENV=prod` plus the file `app.properties` (content: `feature.x=on`)

Preview with `kubectl kustomize work/overlays/dev`, then deploy both with `kubectl apply -k`.
Question: what is the real name of the generated ConfigMap, and why is it not just `dev-web-config`?

Check with `./verify.sh`, clean up with `./teardown.sh`.
