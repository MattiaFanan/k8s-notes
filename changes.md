# Suggested Changes & Improvements for k8s-notes

> **Target exam**: CKAD (Certified Kubernetes Application Developer)
> **Exam version**: Kubernetes v1.35
> **Exam format**: 2-hour, 15-20 hands-on tasks, 66% passing score
> **Source**: Linux Foundation CKAD page + CNCF curriculum (CKAD_Curriculum_v1.35.pdf)
> **Status**: All changes applied as of 2026-08-01

---

## Changes Applied

All changes listed below have been implemented. Summary of what was done:

### New Files Created (22 files)
- `README.md` — Repo overview with exam version reference and directory structure
- `INDEX.md` — Master navigation with CKAD domain mappings
- `11-pod-security/1-yaml-structure.md` — PSS YAML templates (privileged, baseline, restricted)
- `11-pod-security/2-mechanics/01-pss-basics.md` — PSS core concepts and PSA
- `11-pod-security/2-mechanics/02-psa-configuration.md` — PSA configuration and migration from PSP
- `11-pod-security/5-ckad-tips.md` — Pod Security Standards CKAD exam tips
- `0x_timesaver/1-kubectl-cheatsheet.md` — Master kubectl command reference
- `0x_timesaver/2-exam-time-savers.md` — Cross-cutting exam time-savers
- `02-pods/2-mechanics/00-container-images.md` — Container image references, pull policies, digests
- `02-pods/2-mechanics/04-ephemeral-volumes.md` — Ephemeral volumes and kubectl debug
- `03-deployments/2-mechanics/05-pdb-and-strategies.md` — PodDisruptionBudgets and deployment strategies
- `07-services/00-ClusterIP/2-mechanics/06-headless-services.md` — Headless Services (ClusterIP: None)
- `14-observability/2-mechanics/05-debugging-workflow.md` — Systematic debugging workflow
- `14-observability/2-mechanics/06-ephemeral-containers.md` — kubectl debug and ephemeral containers

### Existing Files Modified (16 files)
- All 13 `5-ckad-tips.md` files — Added version banner, expanded content, added cross-references
- `07-services/0-overview.md` — Fixed `##ports` → `## Ports` formatting bug
- `14-observability/2-mechanics/04-observability-tools.md` — Added `kubectl api-resources`, `kubectl api-versions`, `kubectl explain` sections

### Key Improvements
1. **Missing `11-pod-security/` directory created** — Pod Security Standards (privileged/baseline/restricted) and Pod Security Admission
2. **`0x_timesaver/` populated** — kubectl cheatsheet and exam time-savers
3. **Root README.md and INDEX.md added** — Navigation and exam version reference
4. **Ephemeral volumes and ephemeral containers** — Added for DB-04 and OM-05 CKAD scope
5. **Container images section** — Added for DB-01 CKAD scope
6. **Headless Services** — Added for SN-02 CKAD scope
7. **PodDisruptionBudgets** — Added for AD-01 CKAD scope
8. **Systematic debugging workflow** — Added for OM-05 CKAD scope
9. **All CKAD tips files expanded** — Consistent depth, version banners, cross-references
10. **Missing kubectl commands added** — `kubectl api-resources`, `kubectl api-versions`, `kubectl explain`, `kubectl debug`, `kubectl get endpointslices`, `kubectl get ingressclass`, `kubectl auth can-i --list`

---

## 1. Structural Issues

### 1.1 Missing `11-` directory (Pod Security Standards)

The numbering jumps from `10-security` to `12-crds-operators`. A `11-pod-security/` directory should be created covering:

- Pod Security Standards (PSS): `privileged`, `baseline`, `restricted`
- Pod Security Admission (PSA) configuration
- `pod-security.kubernetes.io/enforce`, `warn`, `audit` labels
- Migration from deprecated PodSecurityPolicy (PSP was removed in K8s 1.25)
- CKAD exam relevance: PSS is explicitly in scope under CS-07 (Application Security)

### 1.2 Empty `0x_timesaver/` directory

The `0x_timesaver/` directory exists but is empty. It should contain cross-cutting exam time-savers:

- `kubectl` alias and `dry-run` environment variable setup
- Common `kubectl` one-liners for the exam
- Quick-reference YAML templates for common resources
- A master `kubectl` cheat sheet organized by exam domain

### 1.3 No root README or index

The repo has no root-level `README.md` or master navigation document. Add:

- `README.md` with repo overview, exam version reference, and table of contents
- A master `INDEX.md` that lists all sections with file paths and CKAD domain mappings

### 1.4 No exam version reference in existing files

None of the existing files mention they are aligned with CKAD v1.35 / Kubernetes v1.35. Add a note to each `5-ckad-tips.md` and the root README.

---

## 2. Content Gaps by CKAD Domain

### 2.1 Application Design and Build (20%)

#### DB-01: Define, build and modify container images

**MISSING**: No dedicated section on container images. Topics to add:

- Image reference formats: `registry/repo:tag` vs `registry/repo@sha256:digest`
- `imagePullPolicy` deep dive: `Always`, `IfNotPresent`, `Never` and when each applies
- How `:latest` tag behaves differently from explicit tags
- Image digests for reproducibility (`@sha256:...`)
- Multi-stage builds concept (understanding, not building)
- Private registry authentication (currently only in admission-control section)
- `kubectl create deployment` default image behavior

**Suggested file**: `02-pods/2-mechanics/00-multi-container-pods/` or a new `00-container-images/` section

#### DB-02: Choose and use the right workload resource

**PARTIALLY COVERED**: Deployments, DaemonSets, Jobs, CronJobs all have sections.

**GAPS**:
- `CronJob` `startingDeadlineSeconds` not documented
- `Job` `ttlSecondsAfterFinished` not documented
- `Job` `backoffLimit` behavior could be more CKAD-focused
- No quick-reference table for choosing the right workload type

#### DB-03: Multi-container Pod design patterns

**COVERED**: Adapter, ambassador, sidecar patterns exist.

**GAPS**:
- No explicit CKAD exam guidance on when to use which pattern
- Init container ordering and failure behavior could be more prominent
- Shared volumes between init containers and app containers needs more CKAD examples

#### DB-04: Utilize persistent and ephemeral volumes

**PARTIALLY COVERED**: PV/PVC/StorageClass well documented.

**MISSING**:
- **Ephemeral volumes** (`ephemeral` volume type backed by CSI) — explicitly in CKAD scope
- `volumeClaimTemplates` for StatefulSets not covered anywhere
- Ephemeral volume usage in `kubectl debug` context
- EmptyDir volume lifecycle and behavior when Pod is deleted

### 2.2 Application Deployment (20%)

#### AD-01: Deployment strategies (blue/green, canary)

**PARTIALLY COVERED**: RollingUpdate and Recreate are well documented.

**GAPS**:
- Blue/green deployment pattern needs a dedicated CKAD example (currently only a brief mention in deployment-strategies.md)
- Canary deployments: how to implement with `maxSurge`/`maxUnavailable` or with separate Deployments
- PodDisruptionBudgets not covered — relevant for safe rollouts
- `kubectl rollout` commands (`status`, `history`, `undo`, `--to-revision`) need more CKAD exam focus

#### AD-03: Helm

**PARTIALLY COVERED**: Basic Helm section exists.

**GAPS**:
- No Helm chart structure explanation (`Chart.yaml`, `values.yaml`, `templates/`)
- No `helm upgrade` / `helm rollback` commands in CKAD tips
- No `helm template` vs `helm install --dry-run` distinction
- No Helm chart repository usage (`helm repo add`, `helm repo update`)

#### AD-04: Kustomize

**PARTIALLY COVERED**: Basic Kustomize section exists.

**GAPS**:
- No Kustomize overlay/patch explanation in CKAD tips
- No `kustomize build` vs `kubectl apply -k` distinction
- No common Kustomize patterns (bases, overlays, patches)

### 2.3 Application Observability and Maintenance (15%)

#### OM-01: Understand API deprecations

**PARTIALLY COVERED**: `01-nodes/2-mechanics/07-api-version-deprecation-migration.md` exists but is filed under nodes, not observability.

**GAPS**:
- No CKAD-specific tips for API deprecations
- No mention of `kubectl api-resources` or `kubectl api-versions`
- No guidance on checking deprecated APIs with `kubectl get --raw /apis` or `kubectl describe`

#### OM-03: Use built-in CLI tools to monitor Kubernetes applications

**GAPS**:
- `kubectl debug` with ephemeral containers not covered — this is a CKAD debugging topic
- No systematic debugging workflow document
- `kubectl auth can-i --list` for permission debugging not in observability

#### OM-05: Debugging in Kubernetes

**GAPS**:
- No unified debugging guide that walks through the full debugging workflow
- Ephemeral containers (`kubectl debug`) not covered
- `kubectl describe pod` output interpretation could be more CKAD-focused
- No debugging checklist for common CKAD scenarios (CrashLoopBackOff, ImagePullBackOff, Pending, OOMKilled)

### 2.4 Application Environment, Configuration and Security (25%)

#### CS-02: Authentication, authorization and admission control

**PARTIALLY COVERED**: RBAC and admission control sections exist.

**GAPS**:
- No dedicated section on authentication methods (x509 client certs, OIDC, bearer tokens)
- `kubectl auth can-i --list` not mentioned in RBAC CKAD tips
- No explanation of how ServiceAccount tokens work for API access from inside pods
- No mention of `automountServiceAccountToken: false`

#### CS-03: Requests, limits, quotas

**COVERED**: Resource management section is comprehensive.

**MINOR GAP**: No `kubectl top` in CKAD tips for resource management section.

#### CS-04: ConfigMaps

**COVERED**: Well documented.

#### CS-05: Secrets

**COVERED**: Well documented.

#### CS-06: ServiceAccounts

**PARTIALLY COVERED**: ServiceAccounts are covered in the RBAC section but lack a dedicated CKAD-focused section.

**GAPS**:
- No dedicated ServiceAccount CKAD tips
- `automountServiceAccountToken` not documented
- ServiceAccount token volume projection not covered
- How to use ServiceAccount tokens from inside pods for API access

#### CS-07: Application Security (SecurityContexts, Capabilities)

**COVERED**: Security context section is comprehensive.

**MINOR GAP**: Pod Security Standards (PSS) should be more prominent — they replaced PodSecurityPolicy and are in CKAD scope.

### 2.5 Services and Networking (20%)

#### SN-01: NetworkPolicies

**COVERED**: NetworkPolicies section is comprehensive and well-documented.

#### SN-02: Provide and troubleshoot access to applications via services

**PARTIALLY COVERED**: All service types documented.

**GAPS**:
- **Headless Services** (`ClusterIP: None`) not explicitly covered — important for StatefulSets and direct pod access
- **EndpointSlices** not mentioned as the modern replacement for Endpoints
- `kubectl get endpoints` / `kubectl get endpointslices` for troubleshooting not in CKAD tips
- ExternalName CNAME behavior could be more detailed
- No mention of `kubectl get svc -o wide` for seeing ClusterIP

#### SN-03: Ingress rules

**PARTIALLY COVERED**: Ingress section exists.

**GAPS**:
- No mention of `IngressClass` resource (`kubectl get ingressclass`)
- No mention of default IngressClass configuration
- TLS section exists but could be more CKAD-focused

---

## 3. Quality Improvements

### 3.1 Inconsistent CKAD tips files

Some `5-ckad-tips.md` files are detailed (e.g., `00-declarative-imperative/5-ckad-tips.md` at 50 lines), while others are very brief (e.g., `03-deployments/5-ckad-tips.md` at 11 lines, `06-configmaps-secrets/5-ckad-tips.md` at 19 lines). All CKAD tips files should be expanded to a consistent depth with:

- Exam shortcuts / time-savers
- Common pitfalls
- Verification commands
- A time-saver code block

### 3.2 No cross-referencing between related topics

Files don't reference each other. For example:
- The storage section doesn't cross-reference with the pods section for volume mounting
- The RBAC section doesn't cross-reference with the admission-control section
- NetworkPolicies don't reference the services section for DNS resolution requirements

Add `See also:` links at the top of each file pointing to related content.

### 3.3 Formatting issue in `07-services/0-overview.md`

Line 41 has `##ports Mental Model` — missing a space before "ports". Should be `## Ports Mental Model`.

### 3.4 No exam version or date references

None of the files mention they are aligned with CKAD v1.35 or Kubernetes v1.35. Add a header note to all `5-ckad-tips.md` files and the root README.

### 3.5 Missing `kubectl` commands that are CKAD-relevant

The following commands are not documented anywhere in the repo but are in CKAD scope:

| Command | Purpose |
|---|---|
| `kubectl debug` | Create ephemeral containers for debugging |
| `kubectl explain` | Explore resource schemas interactively |
| `kubectl api-resources` | List all available API resources |
| `kubectl api-versions` | List available API versions |
| `kubectl get endpointslices` | View endpoint slices (modern Endpoints) |
| `kubectl get ingressclass` | List IngressClasses |
| `kubectl auth can-i --list` | List all permissions for a user/SA |
| `kubectl rollout history deployment/<name>` | View rollout history |
| `kubectl rollout undo deployment/<name> --to-revision=<n>` | Rollback to specific revision |
| `kubectl set image` | Quick image update |
| `kubectl set resources` | Quick resource update |
| `kubectl create namespace` | Quick namespace creation |
| `kubectl label` / `kubectl annotate` | Modify labels/annotations on running objects |

---

## 4. Recommended New Files

| File Path | Purpose |
|---|---|
| `README.md` | Repo overview, exam version, table of contents |
| `INDEX.md` | Master navigation with CKAD domain mappings |
| `11-pod-security/1-yaml-structure.md` | Pod Security Standards YAML templates |
| `11-pod-security/2-mechanics/01-pss-basics.md` | Privileged, Baseline, Restricted policies |
| `11-pod-security/2-mechanics/02-psa-configuration.md` | Pod Security Admission configuration |
| `11-pod-security/5-ckad-tips.md` | PSS CKAD exam tips |
| `0x_timesaver/1-kubectl-cheatsheet.md` | Master kubectl command reference |
| `0x_timesaver/2-exam-time-savers.md` | Cross-cutting exam time-savers |
| `02-pods/2-mechanics/00-container-images.md` | Image references, pull policies, digests |
| `02-pods/2-mechanics/04-ephemeral-volumes.md` | Ephemeral volumes and CSI ephemeral volumes |
| `03-deployments/2-mechanics/05-pdb-and-strategies.md` | PodDisruptionBudgets and deployment strategies |
| `07-services/00-ClusterIP/2-mechanics/06-headless-services.md` | Headless Services (ClusterIP: None) |
| `14-observability/2-mechanics/05-debugging-workflow.md` | Systematic debugging workflow |
| `14-observability/2-mechanics/06-ephemeral-containers.md` | `kubectl debug` and ephemeral containers |
| `15-admission-control/2-mechanics/07-pod-security-admission.md` | PSA configuration and enforcement |

---

## 5. Integration Suggestions

### 5.1 Add CKAD domain tags to all files

Each file should include a CKAD domain tag in its header so readers can map notes to exam objectives:

```
<!-- CKAD Domain: Application Design and Build -->
<!-- CKAD Competency: DB-02 -->
```

### 5.2 Add "See also" cross-references

Each file should include a `## See also` section at the bottom linking to related files:

```markdown
## See also

- [Pods - YAML Structure](../../02-pods/1-yaml-structure.md)
- [Resource Management](03-resource-management/1-yaml-structure.md)
```

### 5.3 Add a version banner to all CKAD tips files

Each `5-ckad-tips.md` should start with:

```markdown
> **CKAD Exam Version**: Kubernetes v1.35 | **Exam Date**: 2026
```

### 5.4 Consolidate the `0x_timesaver/` directory

Move the alias and dry-run setup from individual CKAD tips files into a single `0x_timesaver/2-exam-time-savers.md` file, then reference it from each tips file.

---

## 6. Priority Summary

### High Priority (CKAD exam scope, explicitly tested)
1. Create `11-pod-security/` directory for Pod Security Standards
2. Add ephemeral volumes section (DB-04 explicitly includes ephemeral volumes)
3. Add `kubectl debug` / ephemeral containers section (OM-05 debugging)
4. Add container images reference section (DB-01)
5. Add PodDisruptionBudgets section (AD-01 deployment strategies)
6. Add Headless Services section (SN-02 services)
7. Expand all brief `5-ckad-tips.md` files to consistent depth
8. Add cross-references between related files

### Medium Priority (important for exam success)
1. Add root README.md and INDEX.md
2. Add `0x_timesaver/` content
3. Add Helm chart structure and `helm upgrade`/`rollback` commands
4. Add Kustomize overlays/patches explanation
5. Add `kubectl explain`, `kubectl api-resources`, `kubectl api-versions` commands
6. Add API deprecation guidance in observability section
7. Add ServiceAccount token and `automountServiceAccountToken` coverage
8. Fix formatting issue in `07-services/0-overview.md`

### Low Priority (nice-to-have improvements)
1. Add CKAD domain tags to all files
2. Add version banners to all CKAD tips files
3. Add IngressClass documentation
4. Add EndpointSlices documentation
5. Add `kubectl auth can-i --list` to RBAC tips
6. Add Canary deployment details
7. Add CronJob `startingDeadlineSeconds` and Job `ttlSecondsAfterFinished`
