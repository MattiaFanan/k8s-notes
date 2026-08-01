# Monitoring, Logging & API Deprecations - Imperative Commands

## Inspect & Describe

```bash
kubectl describe pod <pod-name>
kubectl describe node <node-name>
kubectl describe deployment <deployment-name>
```

## Events

```bash
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector reason=FailedScheduling
```

## Top / Metrics

```bash
kubectl top node
kubectl top pod --containers
```

## Logs

```bash
kubectl logs <pod-name>
kubectl logs <pod-name> -p
kubectl logs <pod-name> -c <container-name>
kubectl logs <pod-name> --all-containers
kubectl logs -f <pod-name>
```

## API Version Migration

```bash
kubectl api-versions | grep extensions
kubectl get ingress --all-namespaces    # apiVersion should be networking.k8s.io/v1
```

## Cron Job History
```bash
kubectl get jobs
kubectl get cronjobs
```
