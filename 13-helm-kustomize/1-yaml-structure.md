# Helm & Kustomize - YAML Structure

Helm is a package manager for Kubernetes that uses charts—collections of templated YAML files—to define, install, and manage applications. Kustomize is a native Kubernetes tool for customizing YAML manifests without templating, using overlays and patches. This file covers the YAML structure used by both tools, including chart layout, templating syntax, and Kustomization configuration.

## Helm Chart Directory Structure

```text
mychart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
```

## Chart.yaml

```yaml
apiVersion: v2
name: mychart
description: A Helm chart for myapp
version: 0.1.0
appVersion: "1.25"
```

## values.yaml

```yaml
replicaCount: 3
image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent
service:
  port: 80
```

## templates/deployment.yaml (Helm Templating)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-web
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
```

## Kustomization (kustomization.yaml)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
namespace: production
namePrefix: prod-
commonLabels:
  env: prod
images:
- name: nginx
  newName: nginx
  newTag: "1.26"
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|-------|---------------------------|------------------------------|--------------------|
| `Chart.yaml` — `apiVersion` | Required | No (chart-level) | Must be `v2` for modern Helm charts; determines schema validation |
| `Chart.yaml` — `name` | Required | No (chart-level) | Unique identifier for the chart within a repository |
| `Chart.yaml` — `description` | Optional | No (chart-level) | Human-readable description of the chart's purpose |
| `Chart.yaml` — `version` | Required | No (chart-level) | Semver version of the chart itself (not the app) |
| `Chart.yaml` — `appVersion` | Important | No (chart-level) | Version of the application being packaged (e.g. `"1.25"`); often quoted as string |
| `values.yaml` — all entries | Important | No (chart-level) | Default configuration values; overridden by `-f` flag or `--set` CLI options |
| `values.yaml` override precedence | Important | No | `--set` > `-f`/`--values` > `values.yaml` (later sources win) |
| `templates/` — Go templating | Required | No (chart-level) | References: `{{ .Values.xxx }}`, `{{ .Release.Name }}`, `{{ .Chart.Name }}` for dynamic values |
| `Kustomization` — `resources` | Required | Yes (kustomize object) | List of YAML files or directories to include in the build |
| `Kustomization` — `namespace` | Optional | Yes (kustomize object) | Overrides the namespace for all resources in the patch |
| `Kustomization` — `namePrefix` / `nameSuffix` | Optional | Yes (kustomize object) | Prefixes or suffixes added to all resource names |
| `Kustomization` — `commonLabels` | Optional | Yes (kustomize object) | Labels applied to every resource; useful for env or team tagging |
| `Kustomization` — `images` | Optional | Yes (kustomize object) | Updates container image tags (e.g. `newTag: "1.26"`); ideal for tag-only changes |
| `helm install` / `helm upgrade` | Imperative command | N/A | Use `helm install` for first deployment, `helm upgrade` for updates, `helm rollback` for reverting |
| `kubectl apply -k` | Imperative command | N/A | Applies a Kustomize directory directly; equivalent to `kubectl kustomize` piped to `kubectl apply` |
| `kubectl kustomize` | Imperative command | N/A | Prints the rendered YAML without applying; useful for previewing changes |
| Best practice: Kustomize vs Helm | — | — | Use Kustomize for simple overlays and patches; use Helm for packaged apps requiring versioning and templating |
