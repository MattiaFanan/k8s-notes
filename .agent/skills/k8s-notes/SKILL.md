---
name: k8s-notes
description: Manages and curates a structured Kubernetes (CKAD) study notes project with standardized file layouts across numbered domains.
---

# K8s Notes Manager & Curator (CKAD)

This skill manages a structured set of Kubernetes study notes for the Certified Kubernetes Application Developer (CKAD) exam (aligned with official CNCF/Linux Foundation curriculum v1.35).

> **Current date**: 2026-08-02

## Environment

| Field | Value |
|---|---|
| Working directory | `/home/matti/k8s-notes` |
| Workspace root | `/home/matti/k8s-notes` |
| Curriculum version | CNCF/Linux Foundation CKAD v1.35 |

## Organizational Principles

Notes are organized by numbered CKAD domains and submechanics. Each domain and submechanics folder follows the same standardized 5-file layout:

```text
<domain>/
├── 1-yaml-structure.md      # Minimal/essential YAML templates with key fields
├── 2-mechanics/             # Subdirectory with granular in-depth articles
├── 3-imperative-commands.md # Fast `kubectl` commands, dry-run flags, editable vs non-editable fields
├── 4-debugging.md           # Troubleshooting steps, common failure modes, quick remedies
└── 5-ckad-tips.md           # Exam-specific time-savers, shortcuts, and key pitfalls
```

Domains that contain distinct submechanics use a three-level hierarchy: the domain directory contains a top-level set of 5 files plus subdirectories for each submechanics group, each following the same 5-file layout. The `2-mechanics/` subdirectory holds granular articles for each submechanics topic.

---

## Official CKAD Exam Domains & Curriculum Alignment

Ensure notes comprehensively cover all 5 official CKAD domains:

### 1. Application Design and Build (20%)
- Container images (building, modifying, tags)
- Workload primitives (Pods, Deployments, Jobs, CronJobs, DaemonSets)
- Multi-container Pod patterns (Sidecar, Init, Adapter, Ambassador)
- Ephemeral and Persistent Volumes (emptyDir, hostPath, PV, PVC, StorageClass)

### 2. Application Deployment (20%)
- Deployment strategies (RollingUpdate, Recreate, Blue/Green, Canary)
- Rollout management (`rollout status`, `history`, `undo`, `--to-revision`)
- Helm package manager (installing, listing, upgrading, setting values)
- Kustomize (bases, overlays, kustomization.yaml, `kubectl apply -k`)

### 3. Application Observability and Maintenance (15%)
- API deprecations & version migrations
- Health checks & probes (liveness, readiness, startup)
- CLI monitoring tools (`kubectl top pod/node`, metrics-server)
- Container logging (`kubectl logs -f`, `-p`, `--all-containers`)
- Live cluster debugging (`kubectl exec`, `kubectl describe`, `kubectl events`)

### 4. Application Environment, Configuration and Security (25%)
- ConfigMaps & Secrets (env vars, envFrom, volume mounts, secret types)
- SecurityContexts & Capabilities (runAsUser, runAsGroup, readOnlyRootFilesystem, privileged, allowPrivilegeEscalation, capabilities add/drop)
- Resource management (requests, limits, LimitRanges, ResourceQuotas)
- ServiceAccounts & RBAC basics for pods
- Custom Resources (CRDs, Custom Controllers, Operators)
- Admission Control, Authentication & Authorization basics

### 5. Services and Networking (20%)
- Services (ClusterIP, NodePort, LoadBalancer, ExternalName, Port vs TargetPort vs NodePort)
- Ingress rules, ingress controllers, path types, annotations
- NetworkPolicies (ingress, egress, podSelector, namespaceSelector, ipBlock, default-deny)

---

## Content Standards for Standardized Files

### 1. `1-yaml-structure.md`
- Provide clean, minimal, syntax-accurate YAML snippets.
- Use line annotations/comments pointing out essential fields.
- Highlight required vs optional fields relevant to speed on the exam.
- Must contain a **"## Field Reference"** table with columns: Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage.

### 2. `2-mechanics/` articles (`01-*.md`, `02-*.md`, etc.)
- Explain inner workings, lifecycle states, and behavioral logic (e.g. how rolling updates compute surge/unavailable, how PVC binds to PV, how network policies behave with default-deny).
- Address edge cases, default settings (e.g. default restartPolicy, backoffLimit, DNS resolution formats).
- Describe relationships between Kubernetes primitives (e.g., Service selector matching Pod labels).

### 3. `3-imperative-commands.md`
- High-frequency imperative commands (`kubectl run`, `kubectl create`, `kubectl expose`, `kubectl set`, `kubectl annotate`, `kubectl label`).
- Standard dry-run generator flag: `kubectl ... --dry-run=client -o yaml > file.yaml`.
- Explicitly separate **editable fields** (e.g., `spec.containers[*].image`, `spec.activeDeadlineSeconds`, `spec.tolerations`) from **non-editable fields** (which require `kubectl replace --force -f` or deleting and recreating).

### 4. `4-debugging.md`
- Diagnostic commands (`kubectl describe`, `kubectl logs -p`, `kubectl exec -it --`, `kubectl get events --sort-by=.metadata.creationTimestamp`).
- Common failure modes and exact root causes (`CrashLoopBackOff`, `ImagePullBackOff`, `ErrImagePull`, `Pending`, `OOMKilled`, `CreateContainerConfigError`, `SelectorMismatch`).
- Quick recovery steps and verification commands.

### 5. `5-ckad-tips.md`
- Time-saving shortcuts (`alias k=kubectl`, `export do="--dry-run=client -o yaml"`).
- Vim configuration snippet (`set ts=2 sw=2 et`).
- Official documentation search terms and direct doc links permitted during the exam.
- Critical pitfall checklists (e.g., forgetting container ports, wrong selector labels, missing namespace flags).