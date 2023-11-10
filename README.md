# Build a Kubernetes cluster using K3s via Ansible

Author: <https://github.com/itwars>  
Current Maintainer: <https://github.com/dereknola>

Easily bring up a cluster on machines running:

- [X] Debian
- [X] Ubuntu
- [X] Raspberry Pi OS
- [X] RHEL Family (CentOS, Redhat, Rocky Linux...)
- [X] SUSE Family (SLES, OpenSUSE Leap, Tumbleweed...)
- [X] ArchLinux

on processor architectures:

- [X] x64
- [X] arm64
- [X] armhf

## System requirements

The control node must have Ansible 2.10.0+

All managed nodes in inventory must have:
- Passwordless SSH access
- Root access (or a user with equivalent permissions) 

It is also recommended that all managed nodes disable firewalls and swap. See [K3s Requirements](https://docs.k3s.io/installation/requirements) for more information.

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

Setting up a loadbalancer or VIP beforehand to use as the API endpoint is possible but not covered here.


Start provisioning of the cluster using the following command:

```bash
ansible-playbook playbook/site.yml -i inventory.yml
```

## Upgrading

A playbook is provided to upgrade K3s on all nodes in the cluster. To use it, update `k3s_version` with the desired version in `inventory.yml` and run:

```bash
ansible-playbook playbook/upgrade.yml -i inventory.yml
```


## Kubeconfig

After successful bringup, the kubeconfig of the cluster is copied to the control node  and set as default (`~/.kube/config`).
Assuming you have [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) installed, you to confirm access to your **Kubernetes** cluster use the following:

```bash
kubectl get nodes
```

## Local Testing

A Vagrantfile is provided that provision a 5 nodes cluster using Vagrant (LibVirt or Virtualbox as provider). To use it:

```bash
vagrant up
```

By default, each node is given 2 cores and 2GB of RAM and runs Ubuntu 20.04. You can customize these settings by editing the `Vagrantfile`.

## Need More Features?

This project is intended to provide a "vanilla" K3s install. If you need more features, such as:
- Private Registry
- Advanced Storage (Longhorn, Ceph, etc)
- External Database
- External Load Balancer or VIP
- Alternative CNIs

See these other projects:
- https://github.com/PyratLabs/ansible-role-k3s
- https://github.com/techno-tim/k3s-ansible
- https://github.com/jon-stumpf/k3s-ansible
- https://github.com/alexellis/k3sup
