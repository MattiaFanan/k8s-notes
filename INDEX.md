# Index — Kubernetes Notes for CKAD

> **CKAD Exam Version**: Kubernetes v1.35

## Core Concepts

| File | Topic | CKAD Domain |
|------|-------|-------------|
| `00-declarative-imperative/1-yaml-structure.md` | YAML structure fundamentals | Application Design and Build |
| `00-declarative-imperative/5-ckad-tips.md` | Declarative vs imperative exam tips | Application Deployment |
| `01-nodes/1-yaml-structure.md` | Node YAML structure | Application Design and Build |
| `01-nodes/2-mechanics/07-api-version-deprecation-migration.md` | API version deprecation | Observability (OM-01) |
| `01-nodes/5-ckad-tips.md` | Nodes CKAD tips | Application Design and Build |
| `02-pods/1-yaml-structure.md` | Pod YAML structure | Application Design and Build |
| `02-pods/2-mechanics/01-core-mechanics-lifecycle.md` | Pod lifecycle and phases | Application Design and Build |
| `02-pods/2-mechanics/00-multi-container-pods/5-ckad-tips.md` | Multi-container pod tips | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/5-ckad-tips.md` | Taints/tolerations CKAD tips | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/5-ckad-tips.md` | Affinity/anti-affinity CKAD tips | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/5-ckad-tips.md` | Resource management CKAD tips | Application Environment (CS-03) |
| `02-pods/5-ckad-tips.md` | Pods CKAD tips | Application Design and Build |
| `03-deployments/1-yaml-structure.md` | Deployment/Job/CronJob YAML | Application Deployment |
| `03-deployments/2-mechanics/02-deployment-strategies.md` | Deployment strategies | Application Deployment (AD-01) |
| `03-deployments/5-ckad-tips.md` | Deployments CKAD tips | Application Deployment |
| `04-daemonsets/5-ckad-tips.md` | DaemonSets CKAD tips | Application Design and Build (DB-02) |
| `05-storage/1-yaml-structure.md` | Storage YAML structure | Application Design and Build (DB-04) |
| `05-storage/5-ckad-tips.md` | Storage CKAD tips | Application Design and Build (DB-04) |
| `06-configmaps-secrets/1-yaml-structure.md` | ConfigMap/Secret YAML | Application Environment (CS-04, CS-05) |
| `06-configmaps-secrets/5-ckad-tips.md` | ConfigMaps/Secrets CKAD tips | Application Environment (CS-04, CS-05) |
| `07-services/0-overview.md` | Services overview | Services and Networking |
| `07-services/00-ClusterIP/5-ckad-tips.md` | ClusterIP CKAD tips | Services and Networking (SN-02) |
| `07-services/01-NodePort/5-ckad-tips.md` | NodePort CKAD tips | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/5-ckad-tips.md` | LoadBalancer CKAD tips | Services and Networking (SN-02) |
| `07-services/03-ExternalName/5-ckad-tips.md` | ExternalName CKAD tips | Services and Networking (SN-02) |
| `07-services/04-Ingress/5-ckad-tips.md` | Ingress CKAD tips | Services and Networking (SN-03) |
| `08-networkpolicies/5-ckad-tips.md` | NetworkPolicies CKAD tips | Services and Networking (SN-01) |
| `09-rbac/5-ckad-tips.md` | RBAC CKAD tips | Application Environment (CS-02, CS-06) |
| `10-security/5-ckad-tips.md` | Security contexts CKAD tips | Application Environment (CS-07) |
| `11-pod-security/5-ckad-tips.md` | Pod Security Standards CKAD tips | Application Environment (CS-07) |
| `12-crds-operators/5-ckad-tips.md` | CRDs/Operators CKAD tips | Application Environment (CS-01) |
| `13-helm-kustomize/5-ckad-tips.md` | Helm/Kustomize CKAD tips | Application Deployment (AD-03, AD-04) |
| `14-observability/5-ckad-tips.md` | Observability CKAD tips | Observability (OM-01 to OM-05) |
| `15-admission-control/5-ckad-tips.md` | Admission control CKAD tips | Application Environment (CS-02) |

## Exam Time-Savers

| File | Purpose |
|------|---------|
| `0x_timesaver/1-kubectl-cheatsheet.md` | Master kubectl command reference |
| `0x_timesaver/2-exam-time-savers.md` | Cross-cutting exam time-savers |

## Extra

| File | Purpose |
|------|---------|
| `EXTRA/plugins/` | Plugin deep-dives (CNI, CSI, CRI, auth, scheduler, DNS, kubectl) |

## CKAD Domain Mapping

- **Application Design and Build (20%)**: `02-pods/`, `03-deployments/`, `04-daemonsets/`
- **Application Deployment (20%)**: `03-deployments/`, `13-helm-kustomize/`
- **Application Observability and Maintenance (15%)**: `14-observability/`
- **Application Environment, Configuration and Security (25%)**: `05-storage/`, `06-configmaps-secrets/`, `09-rbac/`, `10-security/`, `11-pod-security/`, `15-admission-control/`
- **Services and Networking (20%)**: `07-services/`, `08-networkpolicies/`
