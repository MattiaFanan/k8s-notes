# Plugins - Debugging

This file covers common failures and recovery steps for each plugin layer.

## CNI Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| `NetworkUnavailable=True` stuck on node | CNI DaemonSet crash-looped or not running | `kubectl logs -n kube-system -l k8s-app=calico-node`; check CNI config ConfigMap |
| Pods in `CrashLoopBackOff` with `NetworkPlugin cni failed` | CNI config error or missing binary | Verify ConfigMap `conf.json`; reinstall CNI DaemonSet |
| Cross-node communication fails | CNI plugin does not support hairpin or overlay misconfigured | Check CNI plugin logs and network interfaces (`cni0`, `veth`) |
| NetworkPolicy has no effect | CNI plugin does not enforce policies | Verify CNI supports NetworkPolicy (Calico, Cilium, Antrea, Weave Net); Flannel does not enforce |

## Storage Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| PVC stuck in `Pending` | Provisioner plugin not found | Check StorageClass `provisioner` field matches installed CSI driver |
| Volume attach fail | CSI node plugin not running on target node | `kubectl get pods -n kube-system -l app=csi-ebs-node -o wide` |
| `in-tree plugin conflict` | Both in-tree and CSI driver managing same volume | Disable in-tree plugin or enable CSI migration |
| Pod `CreateContainerConfigError` for volume | CSI driver does not support requested `fsType` or `csi.storage.k8s.io/fstype` | Check driver documentation for supported filesystems |

## Admission Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| `Internal error occurred: failed calling webhook` | Webhook service unreachable or TLS misconfigured | `kubectl get endpoints -n kube-system <webhook-svc>`; check webhook `caBundle` |
| Webhook timeout causes API slowness | Webhook takes too long to respond | Set `timeoutSeconds` in webhook config; ensure webhook is highly available |
| Mutation not applied | Wrong `objectSelector` or `namespaceSelector` in webhook rules | Verify selectors match target objects; `kubectl get <resource> -o yaml` |

## Authentication Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| `Unauthorized` | Token expired, wrong user, or RBAC missing | `kubectl config view`; verify current context and user; check ClusterRoleBinding |
| `Expired token` | OIDC or exec-based token needs refresh | Re-login with `kubectl login` or run exec plugin refresh command |
| ServiceAccount cannot access API | Missing Role/ClusterRole binding | `kubectl get rolebinding,clusterrolebinding -A | grep <sa-name>` |

## Scheduler Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| Pod stuck in `Pending` with no events | Scheduler filter plugin rejected all nodes | `kubectl describe pod <pod>`; check for `FailedScheduling` message |
| `node(s) had taint that the pod didn't tolerate` | TaintToleration plugin enforced node isolation | Add matching toleration to pod spec |
| PVC binding delays pod scheduling | VolumeBinding plugin waiting for `WaitForFirstConsumer` | Provision PV first or change binding mode to `Immediate` |

## kubectl Plugin Failures

| Symptom | Root Cause | Quick Fix |
|---|---|---|
| `Error: unknown command "<plugin>"` | Plugin not in `PATH` or not executable | `kubectl plugin list`; ensure `kubectl-<name>` is executable and in `PATH` |
| Wrong version runs | Duplicate plugin earlier in `PATH` | `kubectl plugin list` shows all matches; reorder `PATH` or rename |
| Plugin crashes | Plugin binary incompatible or missing dependency | Run plugin directly (e.g., `kubectl-tree --help`) to see native error |
