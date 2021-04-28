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

```bash
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

## Kubeconfig

The following describes how to get remote access to your k3s **Kubernetes** cluster.

### Prerequisites

- The master node must have a publicly exposed IP address.
- The master node must allow traffic to and from port 6443.

### Simple Method

```bash
cp ~/.kube/config ~/.kube/config.bak
scp debian@master_ip:.kube/config ~/.kube/config
```

The above assumes you are only accessing a single cluster.
You can now access your cluster with `kubectl`

### Advanced Method; Multiple Cluster Access

```bash
scp debian@master_ip:.kube/config ~/.kube/config-k3s
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config-k3s
```

Update the IP address in the `server` field in `$HOME/.kube/config-k3s` to the master node's publicly exposed IP address.

To avoid conflicts with any existing kubeconfig entries also do the following:

The value `my-k3s-cluster` used below is only an example, any other value that doesn't already exist within your kubeconfig files can be used.

- Update the `name` field under `cluster` to `my-k3s-cluster`.
- Update the `name` field under `context` to `my-k3s-cluster`.
- Update the `cluster` field under `context` to `my-k3s-cluster`.
- Update the `current-context` field to `my-k3s-cluster`.

#### Point kubectl to your k3s cluster

Switch to the `my-k3s-cluster` context with `kubectl config`.

```bash
kubectl config use-context my-k3s-cluster
```
