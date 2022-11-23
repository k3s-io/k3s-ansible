# Build a Kubernetes cluster using k3s via Ansible

Author: <https://github.com/itwars>

## K3s Ansible Playbook

Build a Kubernetes cluster using Ansible with k3s. The goal is easily install a Kubernetes cluster on machines running:

- [X] Debian
- [X] Ubuntu
- [X] CentOS

on processor architecture:

- [X] x64
- [X] arm64
- [X] armhf

## System requirements

Deployment environment must have Ansible 2.4.0+
Master and nodes must have passwordless SSH access

## Usage

First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above. For example:

```ini
[master]
192.16.35.12

[node]
192.16.35.[10:11]

[k3s_cluster:children]
master
node
```

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment.

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

Now K3S cluster is created.

## External Kubectl (from host)

### setup kubectl

- install kubectl

  - Download the latest release with the command:

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```

  - Install kubectl

    ```bash
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    ```

  - Test to ensure the version you installed is up-to-date:

    ```bash
    kubectl version --client
    ```

  - configuring tab completion for kubectl:
    `$ source <(kubectl completion bash)`
    `$ complete -o default -F __start_kubectl k`

- copy master node's /etc/rancher/k3s/k3s.yaml to host's ~/.kube/config

- replace 127.0.0.1 to master node's ip address (by multipass list)
  now you can run from host: `kubectl get nodes` and get same return as run this from master node: `sudo kubectl get nodes`

### commands work for host and each node

Note: no need sudo if executing kubectl from host

```bash
# ubuntu@k3s-master:~$ 
sudo kubectl get nodes
sudo kubectl get nodes -o wide
sudo kubectl get pods -n kube-system
# Retrieve the master node token
sudo cat /var/lib/rancher/k3s/server/node-token
# for both master & worker nodes:
k3s check-config
```

### [install helm && Traefik (to host)](https://www.ivankrizsan.se/2020/10/31/hot-ingress-in-the-k3s-cluster/)

```shell
# ubuntu@k3s-master:~$ 
# helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
# traefic
# add Taefik 2's Helm chart repository:
helm repo add traefik https://helm.traefik.io/traefik
# Update local information of available charts from chart repositories:
helm repo update
# Create a Kubernetes namespace in which to install Traefik 2:
kubectl create ns traefik-v2
# install Taefik as default
helm install --namespace=traefik-v2 traefik traefik/traefik
# install with customized Taefic Helm chart value
helm install --namespace=traefik-v2 --values=./values.yaml traefik traefik/traefik

# verify Traefic pods have been started
sudo kubectl get pods -n=traefik-v2 -o wide
sudo kubectl get pods -n traefik-v2 --selector "app.kubernetes.io/name=traefik" --output name
# output: pod/traefik-d47795995-68ctl

# port forward
sudo kubectl port-forward -n traefik-v2 pod/traefik-d47795995-68ctl 9000:9000
```

Token
> K101ccd4b2ee313a904b2df9d9058ed9078a4ea0e11a1603fbb2f8ce4f290a8ef66::server:554813bd8ee1965985fc8e3482f4b006

### Traefic dashboard

- List the Traefik pod:

	```kubectl get pods -n traefik-v2 --selector "app.kubernetes.io/name=traefik" --output name```

​	example output:

> pod/traefik-76bdd6495d-kmhg4

- Forward requests 

    ```shell
    kubectl port-forward -n traefik-v2 pod/traefik-7fb947cdf7-sjjf8 9000:9000
    ```

In a browser, navigate to http://127.0.0.1:9000/dashboard/

## K3S dashboard

[](https://docs.k3s.io/installation/kube-dashboard)
follow the guide but do it in host so don't need `sudo k3s`, `kubectl --` is just OK.

- create two resource manifest files: dashboard.admin-user-role.yml, dashboard.admin-user.yml ($HOME/g'y/k3s/dashboart)

- Deploy the `admin-user` configuration:

  ```bash
  kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
  ```

- Obtain the Bearer Token

    ```bash
    sudo k3s kubectl -n kubernetes-dashboard create token admin-user
    ```

## Deploying your application

[Running your first application on Kubernetes](https://wangwei1237.github.io/Kubernetes-in-Action-Second-Edition/docs/Running_your_first_application_on_Kubernetes.html)

Usually, to deploy an application, you’d prepare a JSON or YAML file describing all the components that your application consists of and apply that file to your cluster. This would be the declarative approach.

Since this may be your first time deploying an application to Kubernetes, let’s choose an easier way to do this. We’ll use simple, one-line imperative commands to deploy your application. Creating a Deployment:

`$ kubectl create deployment kubia --image=luksa/kubia:1.0`

> The Deployment object is now stored in the Kubernetes API. The existence of this object tells Kubernetes that the luksa/kubia:1.0 container must run in your cluster. You’ve stated your desired state. Kubernetes must now ensure that the actual state reflects your wishes.

> To help you visualize what happened when you created the Deployment, see figure 3.9.
![Figure 3.9 How creating a Deployment object results in a running application container](/home/epi/gary/github/k3s-ansible-official/resource/3.9.png)
Figure 3.9 How creating a Deployment object results in a running application container 

When you ran the kubectl create command, it created a new Deployment object in the cluster by sending an HTTP request to the Kubernetes API server. Kubernetes then created a new Pod object, which was then assigned or scheduled to one of the worker nodes. The Kubernetes agent on the worker node (the Kubelet) became aware of the newly created Pod object, saw that it was scheduled to its node, and instructed Docker to pull the specified image from the registry, create a container from the image, and execute it.

> DEFINITION 
>
> The term scheduling refers to the assignment of the pod to a node. The pod runs immediately, not at some point in the future. Just like how the CPU scheduler in an operating system selects what CPU to run a process on, the scheduler in Kubernetes decides what worker node should execute each container. Unlike an OS process, once a pod is assigned to a node, it runs only on that node. Even if it fails, this instance of the pod is never moved to other nodes, as is the case with CPU processes, but a new pod instance may be created to replace it.

```bash
# Listing deployments
$ kubectl get deployments
$ kubectl get pods

```

## Exposing your application to the world

Your application is now running, so the next question to answer is how to access it. I mentioned that each pod gets its own IP address, but this address is internal to the cluster and not accessible from the outside. **To make the pod accessible externally, you’ll expose it by creating a Service object.**

Several types of Service objects exist. You decide what type you need. Some expose pods only within the cluster, while others expose them externally. **A service with the type LoadBalancer provisions an external load balancer, which makes the service accessible via a public IP. This is the type of service you’ll create now**.
### Creating a Service

```bash
$ kubectl expose deployment kubia --type=LoadBalancer --port 8080
service/kubia exposed

$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP                   PORT(S)          AGE
kubernetes   ClusterIP      10.43.0.1       <none>                        443/TCP          21h
kubia        LoadBalancer   10.43.215.209   10.250.154.175,10.250.154.3   8080:31693/TCP   40m
$ kubectl get svc kubia
```

Some expose pods only within the cluster, while others expose them externally. A service with the type **LoadBalancer** provisions an external load balancer, which makes the service accessible via a public IP.

```shell
$ curl 10.250.154.175:8080 # or curl 10.250.154.3:8080
Hey there, this is kubia-9d785b578-p449x. Your IP is ::ffff:1.2.3.4.
```

 Anyone who knows its IP and port can now access it. If you don’t count the steps needed to deploy the cluster itself, only two simple commands were needed to deploy your application:

- `kubectl create deployment` 
- `kubectl expose deployment`

Your service is accessible directly to worker node as well:

`curl 10.250.154.3:31693`

Note port 31693 if obtained from `$ kubectl get svc kubia`, Your service is accessible via this port number on all your worker nodes, regardless of whether you’re using Minikube or any other Kubernetes cluster.

## Horizontally scaling the application

You now have a running application that is represented by a Deployment and exposed to the world by a Service object. Now let’s create some additional magic.

To run additional instances, you only need to scale the Deployment object with the following command:

```bash
$ kubectl scale deployment kubia --replicas=3
deployment.apps/kubia scaled
```

You’ve now told Kubernetes that you want to run three exact copies or replicas of your pod. Note that you haven’t instructed Kubernetes what to do. You haven’t told it to add two more pods. You just set the new desired number of replicas and let Kubernetes determine what action it must take to reach the new desired state.

This is one of the most fundamental principles in Kubernetes. Instead of telling Kubernetes what to do, you simply set a new desired state of the system and let Kubernetes achieve it. To do this, it examines the current state, compares it with the desired state, identifies the differences and determines what it must do to reconcile them.
