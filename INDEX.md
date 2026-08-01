# Index — Kubernetes Notes for CKAD

> **CKAD Exam Version**: Kubernetes v1.35

## Core Concepts

| File | Topic | CKAD Domain |
|------|-------|-------------|
| `00-declarative-imperative/1-yaml-structure.md` | YAML structure fundamentals | Application Design and Build |
| `00-declarative-imperative/2-mechanics/01-core-definitions.md` | Declarative vs imperative core definitions | Application Design and Build |
| `00-declarative-imperative/2-mechanics/02-declarative-tools-beyond-apply.md` | Declarative tools beyond kubectl apply | Application Design and Build |
| `00-declarative-imperative/2-mechanics/03-drift-detection.md` | Drift detection and reconciliation | Application Design and Build |
| `00-declarative-imperative/2-mechanics/04-history.md` | kubectl apply history | Application Design and Build |
| `00-declarative-imperative/2-mechanics/05-imperative-commands-work.md` | Imperative commands workflow | Application Design and Build |
| `00-declarative-imperative/2-mechanics/06-kubectl-apply-works.md` | How kubectl apply works | Application Design and Build |
| `00-declarative-imperative/3-imperative-commands.md` | Imperative commands reference | Application Design and Build |
| `00-declarative-imperative/4-debugging.md` | Declarative debugging | Application Design and Build |
| `00-declarative-imperative/5-ckad-tips.md` | Declarative vs imperative exam tips | Application Deployment |
| `01-nodes/1-yaml-structure.md` | Node YAML structure | Application Design and Build |
| `01-nodes/2-mechanics/01-setup.md` | Node setup and configuration | Application Design and Build |
| `01-nodes/2-mechanics/02-node-components.md` | Node components (kubelet, kube-proxy, container runtime) | Application Design and Build |
| `01-nodes/2-mechanics/03-node-conditions.md` | Node conditions and status | Application Design and Build |
| `01-nodes/2-mechanics/04-node-lifecycle-registration.md` | Node lifecycle and registration | Application Design and Build |
| `01-nodes/2-mechanics/05-resource-accounting.md` | Node resource accounting | Application Design and Build |
| `01-nodes/2-mechanics/06-kubeconfig.md` | Kubeconfig configuration | Application Design and Build |
| `01-nodes/2-mechanics/07-api-version-deprecation-migration.md` | API version deprecation | Observability (OM-01) |
| `01-nodes/3-imperative-commands.md` | Node imperative commands | Application Design and Build |
| `01-nodes/4-debugging.md` | Node debugging | Application Design and Build |
| `01-nodes/5-ckad-tips.md` | Nodes CKAD tips | Application Design and Build |
| `02-pods/1-yaml-structure.md` | Pod YAML structure | Application Design and Build |
| `02-pods/2-mechanics/00-container-images.md` | Container images, Dockerfile syntax, pull policies | Application Design and Build (DB-01) |
| `02-pods/2-mechanics/00-multi-container-pods/1-yaml-structure.md` | Multi-container pod YAML structure | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/01-adapter-pattern.md` | Adapter pattern | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/02-ambassador-pattern.md` | Ambassador pattern | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/03-init-containers.md` | Init containers | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/04-pod-lifecycle-with-containers.md` | Pod lifecycle with containers | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/05-sidecar-pattern.md` | Sidecar pattern | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/2-mechanics/06-native-sidecar-containers.md` | Native sidecar containers (v1.28+) | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/3-imperative-commands.md` | Multi-container pod imperative commands | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/4-debugging.md` | Multi-container pod debugging | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/00-multi-container-pods/5-ckad-tips.md` | Multi-container pod CKAD tips | Application Design and Build (DB-03) |
| `02-pods/2-mechanics/01-core-mechanics-lifecycle.md` | Pod lifecycle and phases | Application Design and Build |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/1-yaml-structure.md` | Taints/tolerations YAML structure | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/00-node-selector.md` | Node selector scheduling | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/01-common-exam-patterns.md` | Taint/toleration exam patterns | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/02-core-concepts.md` | Taints and tolerations core concepts | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/03-taint-format.md` | Taint format syntax | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/04-toleration-logic.md` | Toleration logic | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/3-imperative-commands.md` | Taint/toleration imperative commands | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/4-debugging.md` | Taint/toleration debugging | Application Environment (CS-03) |
| `02-pods/2-mechanics/01-scheduling-taints-tolerations/5-ckad-tips.md` | Taints/tolerations CKAD tips | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/1-yaml-structure.md` | Affinity YAML structure | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/2-mechanics/01-comparison-taints-tolerations-vs-affinity.md` | Taints vs affinity comparison | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/2-mechanics/02-core-concepts.md` | Scheduling affinity core concepts | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/2-mechanics/03-ignored-during-execution.md` | IgnoredDuringExecution | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/2-mechanics/04-topology-keys.md` | Topology keys | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/3-imperative-commands.md` | Affinity imperative commands | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/4-debugging.md` | Affinity debugging | Application Environment (CS-03) |
| `02-pods/2-mechanics/02-scheduling-affinity/5-ckad-tips.md` | Affinity/anti-affinity CKAD tips | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/1-yaml-structure.md` | Resource management YAML structure | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/01-cpu-units.md` | CPU units | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/02-limitrange-behavior.md` | LimitRange behavior | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/03-memory-units.md` | Memory units | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/04-qos-classes.md` | QoS classes | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/05-requests-vs-limits.md` | Requests vs limits | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/2-mechanics/06-resourcequota-behavior.md` | ResourceQuota behavior | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/3-imperative-commands.md` | Resource management imperative commands | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/4-debugging.md` | Resource management debugging | Application Environment (CS-03) |
| `02-pods/2-mechanics/03-resource-management/5-ckad-tips.md` | Resource management CKAD tips | Application Environment (CS-03) |
| `02-pods/2-mechanics/04-security/1-yaml-structure.md` | Pod security YAML structure | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/2-mechanics/01-key-security-fields.md` | Key security context fields | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/2-mechanics/02-pss-basics.md` | Pod Security Standards basics | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/2-mechanics/03-limitrange-resourcequota.md` | LimitRange and ResourceQuota | Application Environment (CS-03) |
| `02-pods/2-mechanics/04-security/2-mechanics/04-psa-configuration.md` | PSA configuration | Application Environment (CS-02) |
| `02-pods/2-mechanics/04-security/2-mechanics/05-probes-behavior.md` | Probe behavior and mechanics | Application Observability (OM-02) |
| `02-pods/2-mechanics/04-security/2-mechanics/06-securitycontext-scoping.md` | SecurityContext scoping rules | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/3-imperative-commands.md` | Security imperative commands | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/4-debugging.md` | Security debugging | Application Environment (CS-07) |
| `02-pods/2-mechanics/04-security/5-ckad-tips.md` | Pod security CKAD tips | Application Environment (CS-07) |
| `02-pods/2-mechanics/05-ephemeral-volumes.md` | Ephemeral volumes (emptyDir, CSI, ConfigMap/Secret, kubectl debug) | Application Design and Build (DB-04) |
| `02-pods/3-imperative-commands.md` | Pod imperative commands | Application Design and Build |
| `02-pods/4-debugging.md` | Pod debugging | Application Observability (OM-05) |
| `02-pods/5-ckad-tips.md` | Pods CKAD tips | Application Design and Build |
| `03-deployments/1-yaml-structure.md` | Deployment/Job/CronJob YAML | Application Deployment |
| `03-deployments/2-mechanics/01-deployment-rollout-revision-mechanics.md` | Deployment rollout and revision mechanics | Application Deployment (AD-02) |
| `03-deployments/2-mechanics/02-deployment-strategies.md` | Deployment strategies (RollingUpdate, Recreate, Blue/Green, Canary) | Application Deployment (AD-01) |
| `03-deployments/2-mechanics/03-job-cronjob-behavior.md` | Job and CronJob behavior | Application Design and Build (DB-02) |
| `03-deployments/2-mechanics/05-pdb-and-strategies.md` | PodDisruptionBudgets and strategies | Application Deployment (AD-01) |
| `03-deployments/3-imperative-commands.md` | Deployment imperative commands | Application Deployment |
| `03-deployments/4-debugging.md` | Deployment debugging | Application Deployment |
| `03-deployments/5-ckad-tips.md` | Deployments CKAD tips | Application Deployment |
| `04-daemonsets/1-yaml-structure.md` | DaemonSet YAML structure | Application Design and Build (DB-02) |
| `04-daemonsets/2-mechanics/01-core-behavior.md` | DaemonSet core behavior | Application Design and Build (DB-02) |
| `04-daemonsets/2-mechanics/02-rolling-update-strategies.md` | DaemonSet rolling update strategies | Application Design and Build (DB-02) |
| `04-daemonsets/2-mechanics/03-typical-use-cases.md` | DaemonSet typical use cases | Application Design and Build (DB-02) |
| `04-daemonsets/2-mechanics/04-update-behavior.md` | DaemonSet update behavior | Application Design and Build (DB-02) |
| `04-daemonsets/3-imperative-commands.md` | DaemonSet imperative commands | Application Design and Build (DB-02) |
| `04-daemonsets/4-debugging.md` | DaemonSet debugging | Application Design and Build (DB-02) |
| `04-daemonsets/5-ckad-tips.md` | DaemonSets CKAD tips | Application Design and Build (DB-02) |
| `05-storage/1-yaml-structure.md` | Storage YAML structure | Application Design and Build (DB-04) |
| `05-storage/2-mechanics/01-access-modes.md` | Storage access modes | Application Design and Build (DB-04) |
| `05-storage/2-mechanics/02-common-ckad-storage-types.md` | Common CKAD storage types | Application Design and Build (DB-04) |
| `05-storage/2-mechanics/03-reclaim-policies.md` | Storage reclaim policies | Application Design and Build (DB-04) |
| `05-storage/2-mechanics/04-volume-lifecycle-binding.md` | Volume lifecycle and binding | Application Design and Build (DB-04) |
| `05-storage/2-mechanics/05-storageclass.md` | StorageClass deep dive | Application Design and Build (DB-04) |
| `05-storage/3-imperative-commands.md` | Storage imperative commands | Application Design and Build (DB-04) |
| `05-storage/4-debugging.md` | Storage debugging | Application Design and Build (DB-04) |
| `05-storage/5-ckad-tips.md` | Storage CKAD tips | Application Design and Build (DB-04) |
| `06-configmaps-secrets/1-yaml-structure.md` | ConfigMap/Secret YAML structure | Application Environment (CS-04, CS-05) |
| `06-configmaps-secrets/2-mechanics/01-combination-patterns.md` | ConfigMap/Secret combination patterns | Application Environment (CS-04, CS-05) |
| `06-configmaps-secrets/2-mechanics/02-configmap-behavior.md` | ConfigMap behavior | Application Environment (CS-04) |
| `06-configmaps-secrets/2-mechanics/03-secret-behavior.md` | Secret behavior | Application Environment (CS-05) |
| `06-configmaps-secrets/3-imperative-commands.md` | ConfigMap/Secret imperative commands | Application Environment (CS-04, CS-05) |
| `06-configmaps-secrets/4-debugging.md` | ConfigMap/Secret debugging | Application Environment (CS-04, CS-05) |
| `06-configmaps-secrets/5-ckad-tips.md` | ConfigMaps/Secrets CKAD tips | Application Environment (CS-04, CS-05) |
| `07-services/0-overview.md` | Services overview | Services and Networking |
| `07-services/00-ClusterIP/1-yaml-structure.md` | ClusterIP YAML structure | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md` | ClusterIP common CKAD patterns | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/02-core-mechanics.md` | ClusterIP core mechanics | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/03-human-friendly-notes.md` | ClusterIP human-friendly notes | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/04-related-concepts.md` | ClusterIP related concepts | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/05-traffic-flow.md` | ClusterIP traffic flow | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/2-mechanics/06-headless-services.md` | Headless services | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/3-imperative-commands.md` | ClusterIP imperative commands | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/4-debugging.md` | ClusterIP debugging | Services and Networking (SN-02) |
| `07-services/00-ClusterIP/5-ckad-tips.md` | ClusterIP CKAD tips (endpoints, DNS, pitfalls) | Services and Networking (SN-02) |
| `07-services/01-NodePort/1-yaml-structure.md` | NodePort YAML structure | Services and Networking (SN-02) |
| `07-services/01-NodePort/2-mechanics/01-common-ckad-patterns.md` | NodePort common CKAD patterns | Services and Networking (SN-02) |
| `07-services/01-NodePort/2-mechanics/02-core-mechanics.md` | NodePort core mechanics | Services and Networking (SN-02) |
| `07-services/01-NodePort/2-mechanics/03-human-friendly-notes.md` | NodePort human-friendly notes | Services and Networking (SN-02) |
| `07-services/01-NodePort/2-mechanics/04-port-relationship.md` | NodePort port relationship | Services and Networking (SN-02) |
| `07-services/01-NodePort/2-mechanics/05-related-concepts.md` | NodePort related concepts | Services and Networking (SN-02) |
| `07-services/01-NodePort/3-imperative-commands.md` | NodePort imperative commands | Services and Networking (SN-02) |
| `07-services/01-NodePort/4-debugging.md` | NodePort debugging | Services and Networking (SN-02) |
| `07-services/01-NodePort/5-ckad-tips.md` | NodePort CKAD tips | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/1-yaml-structure.md` | LoadBalancer YAML structure | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/2-mechanics/01-common-ckad-patterns.md` | LoadBalancer common CKAD patterns | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/2-mechanics/02-core-mechanics.md` | LoadBalancer core mechanics | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/2-mechanics/03-human-friendly-notes.md` | LoadBalancer human-friendly notes | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/2-mechanics/04-related-concepts.md` | LoadBalancer related concepts | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/2-mechanics/05-session-affinity.md` | Session affinity | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/3-imperative-commands.md` | LoadBalancer imperative commands | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/4-debugging.md` | LoadBalancer debugging | Services and Networking (SN-02) |
| `07-services/02-LoadBalancer/5-ckad-tips.md` | LoadBalancer CKAD tips | Services and Networking (SN-02) |
| `07-services/03-ExternalName/1-yaml-structure.md` | ExternalName YAML structure | Services and Networking (SN-02) |
| `07-services/03-ExternalName/2-mechanics/01-common-pitfalls.md` | ExternalName common pitfalls | Services and Networking (SN-02) |
| `07-services/03-ExternalName/2-mechanics/02-common-use-cases.md` | ExternalName common use cases | Services and Networking (SN-02) |
| `07-services/03-ExternalName/2-mechanics/03-core-mechanics.md` | ExternalName core mechanics | Services and Networking (SN-02) |
| `07-services/03-ExternalName/2-mechanics/04-human-friendly-notes.md` | ExternalName human-friendly notes | Services and Networking (SN-02) |
| `07-services/03-ExternalName/2-mechanics/05-related-concepts.md` | ExternalName related concepts | Services and Networking (SN-02) |
| `07-services/03-ExternalName/3-imperative-commands.md` | ExternalName imperative commands | Services and Networking (SN-02) |
| `07-services/03-ExternalName/4-debugging.md` | ExternalName debugging | Services and Networking (SN-02) |
| `07-services/03-ExternalName/5-ckad-tips.md` | ExternalName CKAD tips | Services and Networking (SN-02) |
| `07-services/04-Ingress/1-yaml-structure.md` | Ingress YAML structure | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/01-common-ckad-patterns.md` | Ingress common CKAD patterns | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/02-core-mechanics.md` | Ingress core mechanics | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/03-human-friendly-notes.md` | Ingress human-friendly notes | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/04-path-types.md` | Ingress path types | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/05-related-concepts.md` | Ingress related concepts | Services and Networking (SN-03) |
| `07-services/04-Ingress/2-mechanics/06-tls.md` | Ingress TLS termination | Services and Networking (SN-03) |
| `07-services/04-Ingress/3-imperative-commands.md` | Ingress imperative commands | Services and Networking (SN-03) |
| `07-services/04-Ingress/4-debugging.md` | Ingress debugging | Services and Networking (SN-03) |
| `07-services/04-Ingress/5-ckad-tips.md` | Ingress CKAD tips | Services and Networking (SN-03) |
| `08-networkpolicies/1-yaml-structure.md` | NetworkPolicy YAML structure | Services and Networking (SN-01) |
| `08-networkpolicies/2-mechanics/01-common-ckad-patterns.md` | NetworkPolicy common CKAD patterns | Services and Networking (SN-01) |
| `08-networkpolicies/2-mechanics/02-core-concepts.md` | NetworkPolicy core concepts | Services and Networking (SN-01) |
| `08-networkpolicies/2-mechanics/03-default-behavior.md` | NetworkPolicy default behavior | Services and Networking (SN-01) |
| `08-networkpolicies/3-imperative-commands.md` | NetworkPolicy imperative commands | Services and Networking (SN-01) |
| `08-networkpolicies/4-debugging.md` | NetworkPolicy debugging | Services and Networking (SN-01) |
| `08-networkpolicies/5-ckad-tips.md` | NetworkPolicies CKAD tips | Services and Networking (SN-01) |
| `09-rbac/1-yaml-structure.md` | RBAC YAML structure | Application Environment (CS-02, CS-06) |
| `09-rbac/2-mechanics/01-aggregation.md` | RBAC aggregation | Application Environment (CS-02) |
| `09-rbac/2-mechanics/02-common-exam-patterns.md` | RBAC common exam patterns | Application Environment (CS-02, CS-06) |
| `09-rbac/2-mechanics/03-core-components.md` | RBAC core components | Application Environment (CS-02) |
| `09-rbac/2-mechanics/04-default-serviceaccount-behavior.md` | Default ServiceAccount behavior | Application Environment (CS-06) |
| `09-rbac/2-mechanics/05-rules-structure.md` | RBAC rules structure | Application Environment (CS-02) |
| `09-rbac/3-imperative-commands.md` | RBAC imperative commands | Application Environment (CS-02, CS-06) |
| `09-rbac/4-debugging.md` | RBAC debugging | Application Environment (CS-02, CS-06) |
| `09-rbac/5-ckad-tips.md` | RBAC CKAD tips | Application Environment (CS-02, CS-06) |
| `10-crds-operators/1-yaml-structure.md` | CRD/Operator YAML structure | Application Environment (CS-01) |
| `10-crds-operators/2-mechanics/01-custom-resource-definition-crd.md` | CRD deep dive | Application Environment (CS-01) |
| `10-crds-operators/2-mechanics/02-custom-resources-crs.md` | Custom Resources | Application Environment (CS-01) |
| `10-crds-operators/2-mechanics/03-operators.md` | Operators | Application Environment (CS-01) |
| `10-crds-operators/2-mechanics/04-relationship.md` | CRD/CR/Operator relationship | Application Environment (CS-01) |
| `10-crds-operators/3-imperative-commands.md` | CRD/Operator imperative commands | Application Environment (CS-01) |
| `10-crds-operators/4-debugging.md` | CRD/Operator debugging | Application Environment (CS-01) |
| `10-crds-operators/5-ckad-tips.md` | CRDs/Operators CKAD tips | Application Environment (CS-01) |
| `11-helm-kustomize/1-yaml-structure.md` | Helm/Kustomize YAML structure | Application Deployment (AD-03, AD-04) |
| `11-helm-kustomize/2-mechanics/01-common-helm-commands.md` | Common Helm commands | Application Deployment (AD-03) |
| `11-helm-kustomize/2-mechanics/02-helm-vs-kustomize.md` | Helm vs Kustomize | Application Deployment (AD-03, AD-04) |
| `11-helm-kustomize/2-mechanics/03-helm.md` | Helm deep dive | Application Deployment (AD-03) |
| `11-helm-kustomize/2-mechanics/04-kustomize.md` | Kustomize deep dive | Application Deployment (AD-04) |
| `11-helm-kustomize/3-imperative-commands.md` | Helm/Kustomize imperative commands | Application Deployment (AD-03, AD-04) |
| `11-helm-kustomize/4-debugging.md` | Helm/Kustomize debugging | Application Deployment (AD-03, AD-04) |
| `11-helm-kustomize/5-ckad-tips.md` | Helm/Kustomize CKAD tips | Application Deployment (AD-03, AD-04) |
| `12-observability/1-yaml-structure.md` | Observability YAML structure | Observability (OM-01 to OM-05) |
| `12-observability/2-mechanics/02-health-probes-recap.md` | Health probes recap | Observability (OM-02) |
| `12-observability/2-mechanics/03-logging-behavior.md` | Container logging behavior | Observability (OM-04) |
| `12-observability/2-mechanics/04-observability-tools.md` | Observability tools | Observability (OM-03) |
| `12-observability/2-mechanics/05-debugging-workflow.md` | Debugging workflow | Observability (OM-05) |
| `12-observability/2-mechanics/06-ephemeral-containers.md` | Ephemeral containers | Observability (OM-05) |
| `12-observability/3-imperative-commands.md` | Observability imperative commands | Observability (OM-03 to OM-05) |
| `12-observability/4-debugging.md` | Observability debugging | Observability (OM-05) |
| `12-observability/5-ckad-tips.md` | Observability CKAD tips | Observability (OM-01 to OM-05) |
| `13-admission-control/1-yaml-structure.md` | Admission control YAML structure | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/01-admission-controllers.md` | Admission controllers | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/02-admission-flow.md` | Admission control flow | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/03-authentication.md` | Authentication | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/04-authorization.md` | Authorization | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/05-csi-ccm.md` | CSI and CCM admission plugins | Application Environment (CS-02) |
| `13-admission-control/2-mechanics/06-imagepullsecrets.md` | ImagePullSecrets admission | Application Environment (CS-05) |
| `13-admission-control/3-imperative-commands.md` | Admission control imperative commands | Application Environment (CS-02) |
| `13-admission-control/4-debugging.md` | Admission control debugging | Application Environment (CS-02) |
| `13-admission-control/5-ckad-tips.md` | Admission control CKAD tips | Application Environment (CS-02) |

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
- **Application Deployment (20%)**: `03-deployments/`, `11-helm-kustomize/`
- **Application Observability and Maintenance (15%)**: `12-observability/`
- **Application Environment, Configuration and Security (25%)**: `05-storage/`, `06-configmaps-secrets/`, `09-rbac/`, `02-pods/2-mechanics/04-security/`, `13-admission-control/`
- **Services and Networking (20%)**: `07-services/`, `08-networkpolicies/`
