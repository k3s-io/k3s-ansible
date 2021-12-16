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
Server and agents must have passwordless SSH access

## Usage

First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above. For example:

```bash
[k3s_server]
192.16.35.12

[k3s_agent]
192.16.35.[10:11]

[k3s_cluster:children]
k3s_server
k3s_agent
```

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment.

Start provisioning of the cluster using the following command:

```bash
ansible-playbook playbook/site.yml -i inventory/my-cluster/hosts.ini
```

## Kubeconfig

To get access to your new **Kubernetes** cluster, just use the generated kube config.

```bash
kubectl --kubeconfig playbook/cluster.conf ...
```
