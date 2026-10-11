# Comments Tracking

| # | File | Line | Comment | Status |
|---|------|------|---------|--------|
| 1 | 05-storage/2-mechanics/02-common-ckad-storage-types.md | 25 | this marmaid is strange, like yes in the node? | solved |
| 2 | 05-storage/2-mechanics/02-common-ckad-storage-types.md | 296 | explain that if secrets and configmaps are mounted as volume, they are eventually updated in 1 or 2 min, as so as long as the app inside the pod reparses them the changes are applied. but subpath are immutabl3 so if used it breaks the automatic update | solved |
| 3 | 05-storage/1-yaml-structure.md | 5 | make sure somewhere in this argoment folder, the fact that pv and pvc exist is to decouple pod volume usage and physical volume properties | solved |
| 4 | 05-storage/1-yaml-structure.md | 25 | hostpath pv without nodeaffinity is not really usefull, add somewhere this class | solved |
| 5 | 07-services/02-LoadBalancer/2-mechanics/05-session-affinity.md | 75 | broken mermaid | solved |
| 6 | 07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md | 80 | explain that endpoints and services are always associated by the same name | solved |
| 7 | 07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md | 127 | i think names are mandatory when multiple ports are used | solved |
| 8 | 07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md | 254 | with final dot i think, explain the 5dots linux serch | solved |
| 9 | 07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md | 312 | this is never explained before, add it to yaml structure | solved |
| 10 | 07-services/00-ClusterIP/2-mechanics/01-common-ckad-patterns.md | 319 | i think svcname.ns is not FQDN but only domain qualified | solved |
| 11 | 07-services/02-LoadBalancer/2-mechanics/02-core-mechanics.md | 2 | make esplicit that the lb is essentially a way to balance the traffic among the nodes, it is better than nodeport cause you can use usual port like 8080 (nodeport goes 30000+) it is cloud managed so if a node goes down you dont loose the ip customer and DNS use, it does tcp connection healthcheck with eternalTrafficPolicy local avoiding the nodeport no-response in case of no matching pod. | solved |
| 12 | 07-services/02-LoadBalancer/2-mechanics/02-core-mechanics.md | 196 | say that lb is node wise while cloudIP is pod wise, and that kubeproxy always tries to redirect to current node pods ("nodeport behavior" - with cluster it can redirect away changing source ip, with local it cant and eventually drops - no response back not event 5** code - the packet if no matching pods on the current node so source ip preserved). with local, tcp healthchecks are executed by lb against kubeproxy health api, and kubeproxy responds 503 if no matching pods in the node, so they result as not available and no lb request is sent to them. | solved |
| 13 | 07-services/02-LoadBalancer/2-mechanics/04-related-concepts.md | 37 | misleading, it seems loadbalancer is a deployment served throug a service. while in reality the served/accessded thing are pods matching the service selector | solved |
| 14 | 07-services/02-LoadBalancer/2-mechanics/04-related-concepts.md | 62 | misleading, seems like ingress controller LB is the external LB and not a deployment of an nginx (or similar) working as lb that is exposed through externallb/nodeport/clusteriip. | solved |
| 15 | 02-pods/2-mechanics/01-scheduling-taints-tolerations/2-mechanics/00-node-selector.md | 134 | seems to me that the tolleration is to allow schedule on manager | solved |
| 16 | 07-services/00-ClusterIP/2-mechanics/02-core-mechanics.md | 48 | broken marmaid | solved |
| 17 | 07-services/00-ClusterIP/2-mechanics/02-core-mechanics.md | 128 | this table is not very understandable | solved |
| 18 | 07-services/00-ClusterIP/2-mechanics/02-core-mechanics.md | 158 | broken marmaid | solved |
| 19 | 07-services/00-ClusterIP/2-mechanics/04-related-concepts.md | 221 | broken maramaid | solved |
| 20 | 07-services/00-ClusterIP/2-mechanics/04-related-concepts.md | 236 | broken mermaid | solved |
| 21 | 06-configmaps-secrets/2-mechanics/02-configmap-behavior.md | 231 | broken mermaid | solved |
| 22 | 07-services/00-ClusterIP/1-yaml-structure.md | 27 | say that the possible values are ClusterIP, NodePort, LoadBalancer, ExternalName. | solved |
| 23 | 07-services/00-ClusterIP/1-yaml-structure.md | 28 | service labels subset of pod labels | solved |
| 24 | 07-services/00-ClusterIP/1-yaml-structure.md | 42 | say that this is actually a virtual IP automatically assigned if not manually set to None | solved |
| 25 | 02-pods/2-mechanics/01-scheduling-taints-tolerations/3-imperative-commands.md | 2 | this page is almost useless, merge with structure | solved |
| 26 | 02-pods/2-mechanics/01-scheduling-taints-tolerations/1-yaml-structure.md | 10 | add remov etaint commad and move here taint fields table | solved |
| 27 | 07-services/04-Ingress/2-mechanics/03-human-friendly-notes.md | 77 | tf is an HA dont spit acronyms | solved |
| 28 | 08-networkpolicies/2-mechanics/02-core-concepts.md | 126 | not very clear | solved |
| 29 | 07-services/04-Ingress/2-mechanics/05-related-concepts.md | 131 | broken mermaid | solved |
| 30 | 07-services/04-Ingress/2-mechanics/05-related-concepts.md | 155 | Standard Kubernetes Ingress controllers (such as ingress-nginx, Traefik, HAProxy, and Envoy-based gateways) watch the Service and its associated EndpointSlices (or legacy Endpoints), extract the individual Pod IPs and ports, and configure their internal reverse proxies (like NGINX upstream blocks) to load-balance traffic directly to those Pod IPs. | solved |
| 31 | 07-services/04-Ingress/2-mechanics/04-path-types.md | 37 | text not completely shown in mermaid | solved |
| 32 | 07-services/04-Ingress/2-mechanics/02-core-mechanics.md | 5 | somewhere in 04 ingress there should be a section on IngressClass, then say that ingress are configurations that the ingress controller polls from the api and autoapply on himeslf, while an ingressClass works as a label to make the controller poll only its ofn configs, while being a concern separation to avoid modifying all ingresses just to change the type of ingress controller. specify the default ingressclass k8s label. | solved |
| 33 | 03-deployments/2-mechanics/05-pdb-and-strategies.md | 148 | point 1cseems contraddictory, review this file and make sense of what uses whaat spi and what api pdb governs | solved |
| 34 | 03-deployments/2-mechanics/02-deployment-strategies.md | 315 | too many unexplained fields in this last part | solved |
| 35 | 03-deployments/2-mechanics/03-job-cronjob-behavior.md | 51 | how can attempt 2 have less failures than attempt 1 | solved |
| 36 | 09-rbac/2-mechanics/01-aggregation.md | 12 | broken mermaid | solved |
| 37 | 09-rbac/2-mechanics/01-aggregation.md | 216 | No, it does not cause undefined behavior, control plane instability, or infinite loops in the Kubernetes API server. | solved |
| 38 | 02-pods/2-mechanics/04-security/2-mechanics/04-psa-configuration.md | 47 | why would i log what i enforced and warn a livel more lenient that cannot be instantiated? | solved |
| 39 | 02-pods/2-mechanics/04-security/2-mechanics/05-probes-behavior.md | 195 | this parameter is never really explained nor in graphs | solved |
| 40 | 04-daemonsets/4-debugging.md | 14 | point 2 is not understandable, explain better with example | unsolved |
| 41 | 04-daemonsets/2-mechanics/03-typical-use-cases.md | 120 | try not to use acronims out of the blue like HPA | unsolved |
| 42 | 02-pods/2-mechanics/04-security/2-mechanics/03-limitrange-resourcequota.md | 182 | this is already elsewhere merge it there | unsolved |
| 43 | 02-pods/2-mechanics/02-scheduling-affinity/2-mechanics/02-core-concepts.md | 305 | add the following somewhere | unsolved |
| 44 | 02-pods/2-mechanics/04-security/2-mechanics/02-pss-basics.md | 115 | add the following somewhere where it fits, or in a new .md file | unsolved |
| 45 | 07-services/03-ExternalName/2-mechanics/03-core-mechanics.md | 156 | say that kubeproxy is a daemonset and need to be restarted if kube-proxy configmap is modified (configmaps update the pods by themselves but some changes need a restart, like switching from iptables to IPVS, so it is good norm to restart in any case), or if it goes out of synch and there is node connectivity problems | unsolved |