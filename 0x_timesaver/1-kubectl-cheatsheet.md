# kubectl Cheat Sheet — CKAD Exam

> **CKAD Exam Version**: Kubernetes v1.35

## Resource Creation

```bash
# Create from a file
kubectl apply -f manifest.yaml

# Create from stdin
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: app
    image: nginx:1.25
EOF

# Quick scaffolding (imperative)
kubectl create deployment web --image=nginx:1.25 --replicas=3
kubectl create service clusterip web-svc --tcp=80:80
kubectl create configmap app-config --from-literal=KEY=VALUE
kubectl create secret generic app-secret --from-literal=KEY=VALUE
kubectl create secret docker-registry regcred --docker-server=registry.io --docker-username=user --docker-password=pass
kubectl create namespace myns
kubectl create serviceaccount my-sa -n myns
kubectl create role my-role --verb=get,list,watch --resource=pods -n myns
kubectl create rolebinding my-binding --role=my-role --user=dev -n myns
kubectl create clusterrole my-cluster-role --verb=get,list,watch --resource=nodes
kubectl create clusterrolebinding my-cluster-binding --clusterrole=my-cluster-role --user=admin
kubectl create pv my-pv --spec=capacity=1Gi,accessModes=ReadWriteOnce,hostPath=/mnt/data
kubectl create pvc my-pvc --storage-class=fast --size=1Gi --access-mode=ReadWriteOnce
kubectl create ingress my-ingress --class=nginx --rule="host/*=svc:80"
kubectl create networkpolicy my-policy --pod-selector=app=web --policy-type=Ingress
kubectl create limitrange my-limits --default=cpu=500m,memory=512Mi -n myns
kubectl create quota my-quota --hard=pods=10,requests.cpu=4 -n myns
kubectl create storageclass fast --provisioner=kubernetes.io/aws-ebs --reclaim-policy=Delete
kubectl create crd mycrs.example.com --spec=group=example.com,versions=v1,names=kind=MyCR,plural=mycrs
```

## Resource Inspection

```bash
# Basic get
kubectl get pods
kubectl get pods -n myns
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Describe
kubectl describe pod mypod -n myns
kubectl describe node worker-1
kubectl describe svc mysvc -n myns
kubectl describe deploy mydeploy -n myns
kubectl describe ingress myingress -n myns
kubectl describe networkpolicy mypolicy -n myns
kubectl describe pvc mypvc -n myns
kubectl describe pv mypv
kubectl describe secret mysecret -n myns
kubectl describe configmap myconfig -n myns
kubectl describe sa my-sa -n myns
kubectl describe role my-role -n myns
kubectl describe clusterrole my-cluster-role
kubectl describe rbac.authorization.k8s.io/rolebinding my-binding -n myns
kubectl describe clusterrolebinding my-cluster-binding

# Events
kubectl get events -n myns --sort-by='.metadata.creationTimestamp'
kubectl get events -n myns --field-selector reason=FailedCreate
kubectl get events -n myns -w

# Logs
kubectl logs mypod -n myns
kubectl logs mypod -n myns -p
kubectl logs mypod -n myns -f
kubectl logs mypod -n myns -c container-name
kubectl logs mypod -n myns --since=1h
kubectl logs mypod -n myns --tail=100

# Resource usage
kubectl top nodes
kubectl top pods -n myns
kubectl top pod mypod -n myns --sort-by=memory

# Auth and permissions
kubectl auth can-i create pods -n myns
kubectl auth can-i get pods --as=system:serviceaccount:myns:my-sa -n myns
kubectl auth can-i --list

# API discovery
kubectl api-resources
kubectl api-versions
kubectl explain pod
kubectl explain pod.spec.containers
kubectl explain deployment.spec.strategy
```

## Resource Modification

```bash
# Edit
kubectl edit pod mypod -n myns
kubectl edit deploy mydeploy -n myns
kubectl edit svc mysvc -n myns

# Set
kubectl set image deployment/mydeploy app=nginx:1.26 -n myns
kubectl set resources deployment/mydeploy cpu=200m,memory=256Mi -n myns
kubectl set replicas deployment/mydeploy=5 -n myns
kubectl set env deployment/mydeploy KEY=VALUE -n myns
kubectl set env deployment/mydeploy --from=configmap/app-config -n myns
kubectl set env deployment/mydeploy --from=secret/app-secret -n myns
kubectl set serviceaccount deployment/mydeploy my-sa -n myns

# Patch
kubectl patch svc mysvc -p '{"spec":{"selector":{"app":"web"}}}' -n myns
kubectl patch deploy mydeploy -p '{"spec":{"replicas":5}}' -n myns
kubectl patch sa default -p '{"imagePullSecrets":[{"name":"regcred"}]}' -n myns
kubectl patch node worker-1 -p '{"spec":{"taints":[{"key":"dedicated","value":"true","effect":"NoSchedule"}]}}'

# Label and annotate
kubectl label pods mypod app=web -n myns
kubectl annotate pods mypod description="production workload" -n myns
```

## Rollout and Scaling

```bash
# Deployment rollouts
kubectl rollout status deployment/mydeploy -n myns
kubectl rollout history deployment/mydeploy -n myns
kubectl rollout history deployment/mydeploy -n myns --revision=2
kubectl rollout undo deployment/mydeploy -n myns
kubectl rollout undo deployment/mydeploy -n myns --to-revision=2

# Scale
kubectl scale deployment/mydeploy --replicas=5 -n myns
kubectl scale --replicas=3 deployment/mydeploy -n myns

# Delete
kubectl delete pod mypod -n myns
kubectl delete deployment mydeploy -n myns
kubectl delete -f manifest.yaml
kubectl delete pods --all -n myns
```

## Debugging

```bash
# Ephemeral debug container
kubectl debug mypod -n myns --image=busybox --target=app
kubectl debug mypod -n myns --image=busybox -it -- sh

# Exec into container
kubectl exec -it mypod -n myns -- sh
kubectl exec -it mypod -n myns -c app-container -- sh

# Run a one-off pod
kubectl run debug-pod --image=busybox -n myns --rm -it --restart=Never -- sh

# Port-forward
kubectl port-forward pod/mypod 8080:80 -n myns
kubectl port-forward svc/mysvc 8080:80 -n myns

# Proxy
kubectl proxy --port=8080
```

## Dry-Run and Validation

```bash
# Dry-run client
kubectl apply -f manifest.yaml --dry-run=client
kubectl create deployment web --image=nginx:1.25 --dry-run=client -o yaml
kubectl run busybox --image=busybox --dry-run=client -o yaml

# Validate
kubectl apply -f manifest.yaml --dry-run=server
kubectl create -f manifest.yaml --validate=true
```

## Namespace and Context

```bash
# Context
kubectl config current-context
kubectl config use-context my-cluster
kubectl config get-contexts
kubectl config view

# Namespace
kubectl config set-context --current --namespace=myns
kubectl get namespaces
kubectl config view --minify --output 'jsonpath={..namespace}'
```