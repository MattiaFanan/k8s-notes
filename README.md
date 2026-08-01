# Kubernetes Notes for CKAD

> **CKAD Exam Version**: Kubernetes v1.35
> **Exam Format**: 2-hour, 15-20 hands-on tasks, 66% passing score
> **Source**: [Linux Foundation CKAD](https://training.linuxfoundation.org/certification/certified-kubernetes-application-developer-ckad/) + [CNCF Curriculum](https://github.com/cncf/curriculum)

## CKAD Exam Domains

| Domain | Weight | Directory |
|--------|--------|-----------|
| Application Design and Build | 20% | `02-pods/`, `03-deployments/` |
| Application Deployment | 20% | `03-deployments/`, `11-helm-kustomize/` |
| Application Observability and Maintenance | 15% | `12-observability/` |
| Application Environment, Configuration and Security | 25% | `05-storage/`, `06-configmaps-secrets/`, `09-rbac/`, `02-pods/2-mechanics/04-security/`, `13-admission-control/` |
| Services and Networking | 20% | `07-services/`, `08-networkpolicies/` |

## Directory Structure

| Directory | Topic |
|-----------|-------|
| `00-declarative-imperative/` | Declarative vs imperative workflows |
| `01-nodes/` | Nodes, kubeconfig, API versions |
| `02-pods/` | Pods, multi-container patterns, scheduling, resource management, security contexts, probes |
| `03-deployments/` | Deployments, Jobs, CronJobs |
| `04-daemonsets/` | DaemonSets |
| `05-storage/` | PV, PVC, StorageClass, volumes |
| `06-configmaps-secrets/` | ConfigMaps and Secrets |
| `07-services/` | ClusterIP, NodePort, LoadBalancer, ExternalName, Ingress |
| `08-networkpolicies/` | NetworkPolicies |
| `09-rbac/` | RBAC and ServiceAccounts |
| `02-pods/2-mechanics/04-security/` | Pod Security Standards, security contexts, probes, limits, quotas |
| `10-crds-operators/` | CRDs and Operators |
| `11-helm-kustomize/` | Helm and Kustomize |
| `12-observability/` | Probes, logging, monitoring, debugging |
| `13-admission-control/` | Admission controllers, webhooks, CSI, ImagePullSecrets |
| `0x_timesaver/` | Cross-cutting exam time-savers |
| `EXTRA/` | Plugin deep-dives (CNI, CSI, CRI, auth, scheduler, DNS, kubectl) |

## CKAD Exam Quick Reference

- **Exam duration**: 2 hours
- **Tasks**: 15-20 hands-on problems
- **Passing score**: 66%
- **Kubernetes version**: v1.35
- **Allowed resources**: [kubernetes.io](https://kubernetes.io), GitHub, Kubernetes blog & subdomains
- **Practice**: [killer.sh](https://killer.sh/) exam simulator

## Study Tips

1. Prioritize **Application Environment, Configuration and Security** (25%) and **Application Design and Build** (20%)
2. Practice `kubectl` commands until they are muscle memory
3. Always use `--dry-run=client -o yaml` to scaffold YAML before editing
4. Start with declarative approach for complex tasks, imperative for quick scaffolding
5. Always verify with `kubectl get`, `kubectl describe`, and `kubectl logs`
