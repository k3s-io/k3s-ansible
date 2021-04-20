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

### Add k3s kubeconfig to your local machine

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config-k3s
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/config-k3s
```

Update the IP address in the `server` field in `$HOME/.kube/config-k3s` to the master node's publicly exposed IP address.

To avoid conflicts with any existing kubeconfig entries also do the following:

The value `my-k3s-cluster` used below is only an example, any other value that doesn't already exist within your kubeconfig files can be used.

- Update the `name` field under `cluster` to `my-k3s-cluster`.
- Update the `name` field under `context` to `my-k3s-cluster`.
- Update the `cluster` field under `context` to `my-k3s-cluster`.
- Update the `current-context` field to `my-k3s-cluster`.

### Point kubectl to your k3s cluster

Switch to the `my-k3s-cluster` context with `kubectl config`.

```bash
kubectl config use-context my-k3s-cluster
```

### If you do not need to preserve existing kubeconfig

Alternatively if you do not need to preserve any existing kubeconfig, you may simply scp the config file to your host, update the IP address and use it as is.

```bash
scp debian@master_ip:.kube/config ~/.kube/config
```

Then edit the IP address to be the master node's publicly exposed IP address.
