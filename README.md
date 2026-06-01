# Project presentation - `inception-of-things`
**Introduction**

*This project was realized in a **trio with [Luma](https://github.com/luma-3) and [Sensei Tarzan](https://github.com/SenseiTarzan)***
*It also uses this [Git repository](https://github.com/bibickette/inception-of-things-gcaptari)*

This README is organized as follows:
- [Description](#description)
- [Repo Layout](#repo-layout)
- [Languages & Technologies](#languages--technologies)
- [Key Concepts](#key-concepts)
- [System Environment](#system-environment)
- [Project Parts](#project-parts)
- [Useful Commands](#useful-commands)
- [How to Use](#how-to-use-iot)
---
 
## Description
 
**Inception-of-Things** (IoT) is a system administration project introducing the fundamentals of container orchestration using **Kubernetes** through its lightweight distributions **K3s** and **K3d**, automated with **Vagrant** and completed with a **GitOps** continuous deployment pipeline using **Argo CD**.
 
### Kubernetes & Orchestration
 
**Kubernetes** (K8s) is an open-source container orchestration platform originally developed by Google. It automates the deployment, scaling, and management of containerized applications across a cluster of machines. Its core unit is the **Pod** : a wrapper around one or more containers sharing the same network and storage. Pods are grouped and managed through **Deployments**, exposed internally via **Services**, and made accessible from outside the cluster through **Ingress** rules.
 
A **cluster** is the set of machines (called **nodes**) managed by Kubernetes. Each cluster has at least one **control-plane node** (the brain : schedules workloads, manages state) and one or more **worker nodes** (the arms : run the actual containers). Kubernetes continuously reconciles the *desired state* (what you declare in YAML files) with the *actual state* (what is currently running).
 
**Replicas** allow running multiple identical pods simultaneously. Kubernetes automatically load-balances traffic across them and restarts any pod that crashes : this is called *auto-healing*.
 
### K3s
 
**K3s** is a certified lightweight Kubernetes distribution created by Rancher. It runs with as little as 512MB of RAM and installs in a single command, making it ideal for edge computing, IoT devices, and learning environments. K3s ships with **Traefik** as its default Ingress controller : a reverse proxy that reads Ingress rules and routes HTTP traffic to the correct service based on the `Host` header.
 
### K3d
 
**K3d** is a tool that runs K3s clusters inside **Docker containers**. Instead of requiring virtual machines, each cluster node becomes a Docker container. This makes cluster creation and teardown almost instantaneous, which is ideal for local development and CI/CD pipelines. K3d automatically creates a **load balancer container** that maps ports from your machine into the cluster.
 
### Argo CD & GitOps
 
**Argo CD** is a declarative continuous delivery tool for Kubernetes. It implements the **GitOps** pattern: your Git repository becomes the single source of truth for your cluster's desired state. Argo CD continuously monitors a target repository and automatically synchronizes the cluster whenever a change is detected. If the cluster drifts from what Git declares, Argo CD corrects it *(self-healing)*.
 
The workflow is: push a change to Git => Argo CD detects it => pulls the new image from Docker Hub => redeploys the application. No manual `kubectl apply` needed.
 
* * *
 
## Repo Layout
 
```
inception-of-things/
│
├── README.md
│
├── p1/                         ← Part 1: K3s cluster with Vagrant (2 nodes)
│   ├── Vagrantfile
│   └── scripts/
│       ├── server.sh           ← Installs K3s in server mode
│       └── worker.sh           ← Installs K3s in agent mode, joins the cluster
│
├── p2/                         ← Part 2: K3s with 3 apps and Ingress routing
│   ├── Vagrantfile
│   ├── scripts/
│   │   ├── server.sh           ← Installs K3s in server mode
│   │   └── setup.sh            ← Deploys apps
│   └── configs/
│       ├── app1.yml
│       ├── app2.yml
│       ├── app3.yml
│       └── ingress.yml
│
├── p3/                         ← Part 3: K3d + Argo CD GitOps pipeline
│   ├── scripts/
│   │   └── setup.sh            ← Create K3d cluster and deploys wil-app
│   └── configs/
│       ├── ingress.yml
│       ├── install.yml
│       └── manifest.yml
│
└── bonus/                      ← Bonus: GitLab running locally in the cluster
==========    *TO UPDATE*
```
 
* * *
 
## Languages & Technologies
 
### Languages
 - **Bash** : All provisioning and setup scripts
 - **YAML** : All Kubernetes resource manifests (Deployments, Services, Ingress, Argo CD Applications). It is the declarative language used by K8s to describe the desired state of resources
 - **Ruby (Vagrantfile)** : Vagrant configuration files are written in Ruby DSL. Used to define virtual machines
 
### Technologies

- **QEMU-KVM** : Hypervisors that actually run the virtual machines
- **Vagrant** : Automates the creation and configuration of virtual machines
- **K3s** : Lightweight certified Kubernetes distribution
- **K3d** : Tool that runs K3s clusters inside Docker containers
- **kubectl** : Official K8s command-line tool. Used to interact with any K8s cluster
- **Argo CD** : GitOps continuous delivery tool for Kubernetes. Monitors a Git repository and automatically synchronizes the cluster with its contents.

 ========== to be coming ? :
| Technology | Role |
|---|---|
| **Helm** | Package manager for Kubernetes (used in bonus). Helm *charts* are pre-packaged application definitions that simplify complex deployments like GitLab. |
| **GitLab CE** | Self-hosted Git repository platform (bonus). Replaces GitHub as the source of truth monitored by Argo CD, running entirely within the local cluster. |
 
* * *
 
## Key Concepts
 
- **Cluster** : a group of machines managed as one by Kubernetes
- **Node** : a single machine (VM or container) in a cluster
- **Pod** : the smallest deployable unit in Kubernetes; wraps one or more containers
- **Deployment** : declares how many replicas of a pod to run and how to update them
- **Replica** : an identical copy of a pod; multiple replicas enable load balancing and fault tolerance
- **Service** : exposes a set of pods on the internal cluster network; load-balances across replicas
- **Ingress** : routes external HTTP traffic to the correct service based on the `Host` header
- **IngressClass** : specifies which Ingress controller (e.g. Traefik) should handle an Ingress resource
- **Namespace** : a logical partition inside a cluster to isolate resources
- **GitOps** : a deployment paradigm where Git is the single source of truth for cluster state
- **Auto-healing** : Kubernetes automatically restarts crashed pods to maintain the desired replica count
- **Reverse proxy** : a server that receives all incoming requests and forwards them to the right backend
- **Node token** : a secret generated by K3s server used to authenticate worker nodes joining the cluster

* * *
 
## System Environment
 
### Host Machine
 
The host virtual machine is built from a **Debian 13 Trixie** disk image and runs with **QEMU/KVM** : a native Linux hypervisor that uses hardware virtualization for near-native performance. The VM is launched with the following command :
 
```bash
qemu-system-x86_64 \
  -m 8192 \                        # 8 GB RAM
  -cpu host \                      # exposes host CPU features to the guest
  -enable-kvm \                    # enables hardware-accelerated virtualization
  -smp 4 \                         # 4 virtual CPU cores
  -drive file=iot.qcow2,format=qcow2 \  # disk image in QCOW2 format
  -netdev user,id=n1 -device virtio-net-pci,netdev=n1 \  # virtio network
  -device virtio-vga \             # virtual GPU for graphical output
  -display gtk                     # display in a GTK window
```
 
This VM serves as the base environment for the entire project. All tools (Vagrant, VirtualBox, Docker, K3d, kubectl) are installed inside it, ensuring a reproducible and isolated workspace for the whole team.
 
### Environment Inside the Project
 
| Part | VM Setup | OS | K3s/K3d mode |
|---|---|---|---|
| **p1** | 2 VMs via Vagrant | Debian 13 Trixie | K3s server + K3s agent |
| **p2** | 1 VM via Vagrant | Debian 13 Trixie | K3s server only |
| **p3** | No Vagrant — K3d directly on host VM | — | K3d cluster (Docker containers) |
| **bonus** | No Vagrant — K3d directly on host VM | — | K3d cluster + GitLab |
 
Parts 1 and 2 use Vagrant to provision **Debian 13** virtual machines. The `Vagrantfile` defines machine names, static IPs, CPU/RAM allocation, and runs provisioning shell scripts automatically on first boot. Parts 3 and bonus run directly on the host VM using K3d, which creates K3s cluster nodes as Docker containers; no additional VMs needed.
 
* * *
 
## Project Parts
 
### p1 : K3s and Vagrant
 
Part 1 introduces the fundamentals of Kubernetes cluster architecture. Two virtual machines are created by a single `Vagrantfile`:
 
- **loginS** (`192.168.56.110`) : runs K3s in **server mode** (control-plane). This node is the brain of the cluster: it hosts the API server, the scheduler, the controller manager, and etcd (the cluster state database). `kubectl` is installed here.
- **loginSW** (`192.168.56.111`) : runs K3s in **agent mode** (worker). This node receives instructions from the server and runs the actual workloads. It authenticates to the server using a **node token** shared via the `/vagrant/` synced folder.
Both nodes communicate over a private Vagrant network. Once provisioned, `kubectl get nodes` on the server should show both nodes with status `Ready`.
 
### p2 : K3s and Three Simple Applications
 
Part 2 introduces **Ingress routing** : how a single IP address can serve multiple different applications based on the HTTP `Host` header. A single VM runs K3s in server mode and hosts three web applications:
 
- **App 1** : 1 replica, accessible via `Host: app1.com`
- **App 2** : **3 replicas** (demonstrates load balancing and fault tolerance), accessible via `Host: app2.com`
- **App 3** : 1 replica, the **default backend** (handles all requests without a matching Host header)

Each application is defined by a `Deployment` (declares the image and replica count) and a `Service` (exposes the pods internally). A single `Ingress` resource with `ingressClassName: traefik` declares the routing rules. Traefik reads these rules and routes requests accordingly.
 
### p3 : K3d and Argo CD
 
Part 3 introduces **GitOps** continuous deployment. Vagrant is no longer used. The cluster runs via **K3d** directly on the host VM, with K3s nodes as Docker containers. A shell script (`p3/scripts/setup.sh`) installs and configures everything from scratch.
 
Two Kubernetes namespaces are created:
- **argocd** : runs Argo CD, which monitors a public GitHub repository
- **dev** : hosts the `wil42/playground` application deployed and managed by Argo CD

The GitOps workflow:
1. The application is reachable at `http://localhost:8888` and shows v1.
2. Edit `application.yml` on GitHub (changing `:v1` to `:v2`) 
3. Argo CD detects the change
   => Pulls the new image from Docker Hub
   => Redeploys the pod automatically.
4. The application is still reachable at `http://localhost:8888` and now shows v2.
 
* * *
 
## Useful Commands
 
### Cluster & Nodes
```bash
kubectl get nodes                        # list all nodes and their status
kubectl get nodes -o wide                # with IPs, OS image, and kernel version
kubectl describe node <node-name>        # detailed info on a node
```
 
### Pods
```bash
kubectl get pods                         # list pods in default namespace
kubectl get pods -A                      # list pods in all namespaces
kubectl get pods -n <namespace>          # list pods in a specific namespace
kubectl get pods -w                      # watch pods in real time
kubectl describe pod <pod-name>          # detailed info and events for a pod
kubectl logs <pod-name>                  # view logs of a pod
kubectl logs <pod-name> -f               # follow logs in real time
kubectl delete pod <pod-name>            # delete a pod (it will be recreated)
kubectl exec -it <pod-name> -- /bin/sh   # open a shell inside a pod
```
 
### Deployments
```bash
kubectl get deployments                  # list deployments
kubectl get deployments -n <namespace>
kubectl describe deployment <name>
```
 
### Services
```bash
kubectl get services                     # list services (short: svc)
kubectl get svc -A                       # all namespaces
kubectl describe svc <name>
```
 
### Ingress
```bash
kubectl get ingress                      # list ingress resources
kubectl get ingress -A
kubectl describe ingress <name>          # shows routing rules and backend services
```
 
### Namespaces
```bash
kubectl get namespaces                   # list all namespaces (short: ns)
kubectl get all -n <namespace>           # all resources in a namespace
kubectl create namespace <name>          # create a namespace
kubectl delete namespace <name>          # delete a namespace
```
 
### Applying & Managing Manifests
```bash
kubectl apply -f <file.yaml>             # create or update a resource from a file
kubectl apply -f <directory/>            # apply all YAML files in a directory
kubectl delete -f <file.yaml>            # delete a resource from a file
kubectl get all                          # list all resources in default namespace
kubectl get all -A                       # list everything in all namespaces
```
 
### K3d
```bash
k3d cluster create <name>               # create a new cluster
k3d cluster create <name> --port "8888:8888@loadbalancer"
k3d cluster list                         # list all K3d clusters
k3d cluster delete <name>               # delete a cluster
k3d cluster stop <name>                  # stop a cluster
k3d cluster start <name>                 # start a stopped cluster
```
 
### Vagrant
```bash
vagrant up                               # create and start all VMs
vagrant up <machine-name>               # start a specific VM
vagrant ssh <machine-name>              # SSH into a VM
vagrant halt                             # shut down all VMs
vagrant destroy -f                       # delete all VMs
vagrant provision                        # re-run provisioning scripts
vagrant status                           # show status of VMs
```
 
### Argo CD
```bash
# Get initial admin password
kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath="{.data.password}" | base64 -d
 
# Port-forward to access the web UI if not opened in the cluster
kubectl port-forward svc/argocd-server -n argocd 8080:443
 
# Check app status
kubectl get application -n argocd
kubectl describe application <app-name> -n argocd
```

========== to see :
```
# Force a sync (if argocd CLI is installed)
argocd app sync <app-name>
```
 
### Debugging
```bash
kubectl describe pod <pod-name> -n <namespace>   # events and error messages
kubectl logs <pod-name> -n <namespace>            # container logs
journalctl -u k3s -f                              # K3s server logs (on the VM)
journalctl -u k3s-agent -f                        # K3s agent logs
```
 
* * *
 
## How to Use `inception-of-things`
 
### Prerequisites
 
- A host machine running Linux with QEMU/KVM support
- The host VM image built from Debian 13 Trixie
- The project uses this [GitHub repository](https://github.com/bibickette/inception-of-things-gcaptari)

1. Clone `inception-of-things` in a folder first  : `git clone https://github.com/bibickette/inception-of-things.git`
2. Go to the part folder you want to see
 
#### Part 1: K3s cluster with two nodes
 
```bash
cd p1
vagrant up          # creates loginS and loginSW, installs K3s on both
vagrant ssh loginS  # connect to the server node
kubectl get nodes   # both nodes should appear as Ready
```
 
#### Part 2: K3s with three applications
 
```bash
cd p2
vagrant up          # creates loginS, installs K3s and deploys the 3 apps
vagrant ssh loginS
kubectl get pods    # 5 pods running (1 + 3 + 1)
kubectl get ingress # check routing rules
 
# Test routing from your machine:
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110   # default → app3
```
 
#### Part 3: K3d and Argo CD
 
```bash
cd p3
bash scripts/setup.sh   # create K3d cluster, installs Argo CD and deploys everything
 
# Check namespaces
kubectl get ns          # argocd and dev should be present
 
# Check the app
curl http://localhost:8888/    # {"status":"ok", "message": "v1"}
 
# Access Argo CD web UI if not opened in the cluster
kubectl port-forward svc/argocd-server -n argocd 8080:443
# open https://localhost:8080 in your browser
```
 
To trigger a redeployment, update `image: wil42/playground:v1` to `:v2` in your GitHub repository. Argo CD will detect the change and redeploy automatically within a few minutes.
 
* * *
 
*Project validation date: TBD*
