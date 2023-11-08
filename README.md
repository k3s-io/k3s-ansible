# Under Construction :construction:

# Build a Kubernetes cluster using k3s via Ansible

Author: <https://github.com/itwars>

## K3s Ansible Playbook

Build a Kubernetes cluster using Ansible with k3s. The goal is easily install a Kubernetes cluster on machines running:

- [X] Debian
- [X] Ubuntu
- [X] CentOS
- [X] ArchLinux

on processor architecture:

- [X] x64
- [X] arm64
- [X] armhf

## System requirements

Deployment environment must have Ansible 2.4.0+
Server and agent nodes must have passwordless SSH access

## Usage

First copy the sample inventory to `inventory.yml`.

```bash
cp inventory-sample.yml inventory.yml
```

Second edit the inventory file to match your cluster setup. For example:
```bash
k3s_cluster:
  children:
    server:
      hosts:
        192.16.35.11
    agent:
      hosts:
        192.16.35.12
        192.16.35.13
```

If needed, you can also edit `vars` section at the bottom to match your environment.

If multiple hosts are in the server group the playbook will automatically setup k3s in HA mode with embedded etcd.
An odd number of server nodes is required (3,5,7). Read the offical documentation below for more information and options.
https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/
Using a loadbalancer or VIP as the API endpoint is preferred but not covered here.


Start provisioning of the cluster using the following command:

```bash
ansible-playbook playbook/site.yml -i inventory.yml
```

## Kubeconfig

After successful bringup, the kubeconfig of the cluster is copied to the control-node and set as default (`~/.kube/config`).
Assuming you have [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) installed, you to confirm access to your **Kubernetes** cluster use the following:

```bash
kubectl get nodes
```

## Local Testing

A Vagrantfile is provided that provision a 5 nodes cluster using LibVirt or Virtualbox and Vagrant. To use it:

```bash
vagrant up
```

By default, each node is given 2 cores and 2GB of RAM and runs Ubuntu 20.04. You can customize these settings by editing the `Vagrantfile`.