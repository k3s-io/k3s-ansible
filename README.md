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

Add the system information gathered above into a file called hosts.ini. For example:

```bash
[master]
192.16.35.12

[node]
192.16.35.[10:11]

[k3s_cluster:children]
master
node

```

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/hosts.ini
```

## Kubeconfig

To get access to your **Kubernetes** cluster just

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config
```
