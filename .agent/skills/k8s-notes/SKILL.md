---
name: k8s-notes
description: Generates and curates a compact set of structured Kubernetes (CKAD) study notes in Markdown format.
---

# K8s Notes Generator & Curator (CKAD)

This skill guides the creation, curation, and maintenance of concise, highly actionable Kubernetes study notes specifically tailored for the Certified Kubernetes Application Developer (CKAD) exam (aligned with official CNCF/Linux Foundation curriculum: K8s v1.35).

## Directory & File Structure

Notes are organized by key CKAD concepts/domains into dedicated directories. Main concepts or specific submechanics (e.g., taints/tolerations, node affinity, sidecars) use the exact same standardized 5-file layout:

```text
<concept>/
├── 1-yaml-structure.md      # Minimal/essential YAML templates with key fields
├── 2-in-depth-mechanics.md  # Core behavior, state transitions, runtime mechanics, edge cases
├── 3-imperative-commands.md # Fast `kubectl` commands, dry-run flags, editable vs non-editable fields
├── 4-debugging.md           # Troubleshooting steps, common failure modes, quick remedies
└── 5-ckad-tips.md           # Exam-specific time-savers, shortcuts, and key pitfalls
```

### Subfolders for Submechanics
For complex concepts with distinct subcomponents or specialized mechanics, create subfolders inside the main concept folder. Each subfolder **must follow the exact same 5-file structure**:

```text
pods/
├── 1-yaml-structure.md
├── 2-in-depth-mechanics.md
├── 3-imperative-commands.md
├── 4-debugging.md
├── 5-ckad-tips.md
├── multi-container/
│   ├── 1-yaml-structure.md
│   ├── 2-in-depth-mechanics.md
│   ├── 3-imperative-commands.md
│   ├── 4-debugging.md
│   └── 5-ckad-tips.md
└── scheduling-taints-tolerations/
    ├── 1-yaml-structure.md
    ├── 2-in-depth-mechanics.md
    ├── 3-imperative-commands.md
    ├── 4-debugging.md
    └── 5-ckad-tips.md
```

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

### 2. `2-in-depth-mechanics.md`
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

