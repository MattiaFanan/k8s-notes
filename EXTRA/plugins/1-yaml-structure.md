# Plugins - YAML Structure

Kubernetes relies on plugins across multiple layers: networking (CNI), storage (CSI, in-tree), admission control, authentication, scheduling, and the kubectl CLI itself. This file covers the YAML structures used to configure or define the most common plugin types.

## CNI Plugin Configuration

CNI plugins are typically configured via a ConfigMap consumed by the CNI DaemonSet.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cni-config
  namespace: kube-system
data:
  conf.json: |
    {
      "cniVersion": "0.4.0",
      "name": "pod-network",
      "type": "calico",
      "log_level": "info",
      "log_file": "/var/log/calico/cni/cni.log",
      "ipam": {
        "type": "calico-ipam"
      }
    }
```

## CSI StorageClass (Plugin-Driven Provisioning)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

## Admission Webhook (Plugin Hook)

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: pod-policy.example.com
webhooks:
- name: pod-policy.example.com
  rules:
  - apiGroups: [""]
    apiVersions: ["v1"]
    operations: ["CREATE"]
    resources: ["pods"]
  clientConfig:
    service:
      namespace: kube-system
      name: my-webhook
      path: /validate-pod
    caBundle: <base64-encoded-ca>
```

## Field Reference

| Field / Pattern | Required | Editable with `kubectl edit` | Notes |
|---|---|---|---|
| CNI ConfigMap `conf.json` | Cluster set-up | Yes | Defines the CNI plugin type and network parameters |
| StorageClass `provisioner` | Required | Yes | Identifies the storage plugin (e.g., `kubernetes.io/aws-ebs`, `csi.storage.k8s.io`) |
| Webhook `rules[].operations` | Required | No (requires restart) | Determines when the admission plugin fires |
| Scheduler `profile` flags | Kubelet arg | No (node-level) | Enables scheduler framework plugins like `NodeResourcesFit` |
