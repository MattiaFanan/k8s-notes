# Monitoring, Logging & API Deprecations - YAML Structure

Observability in Kubernetes relies on monitoring metrics, collecting logs, and inspecting cluster state—most of which is done with `kubectl` commands rather than YAML manifests. The metrics-server exposes resource usage via the Metrics API, while container logs are surfaced at the node level by the container runtime. This file covers the YAML and CLI structures relevant to observability workflows.

## Basic Pod Debug Inspect (Describe)

```bash
# No YAML required; use describe
kubectl describe pod <pod-name>
kubectl describe node <node-name>
```

## Events Sorted

```bash
# Imperative sort (no YAML)
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Metrics API (metrics-server required)

```bash
# No YAML required
kubectl top node
kubectl top pod
kubectl top pod --containers
```

## Container Logging

```yaml
# Not configurable in YAML; log driver is node/container runtime.
# Pod level text logs accessible via:
# kubectl logs <pod-name>
# kubectl logs <pod-name> -c <container-name>
```

## Field Reference

| Field | Required/Optional/Important | Editable with `kubectl edit` | Notes & Best Usage |
|---|---|---|---|
| describe pod | Important | No | Shows Conditions, Containers, Events; preferred over logs for probe/scheduling issues. No YAML structure (imperative only). |
| events --sort-by | Important | No | Shows chronological order via `.metadata.creationTimestamp`. No YAML structure (imperative only). |
| top node/pod | Important | No | Requires metrics-server deployment. No YAML structure (imperative only). |
| logs (-p / default / --all-containers) | Important | No | Previous crashed container via `-p`; current via default; all containers via `--all-containers` flag. No YAML structure (imperative only). |
| apiVersion | Required | Yes | Check `kubectl api-versions` for deprecations; edit YAML apiVersion and re-apply. |
```
