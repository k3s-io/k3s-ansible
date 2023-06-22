Fork of the [k3s-ansible](https://github.com/k3s-io/k3s-ansible) project that includes work  done part of the [openSUSE hackweek 21](https://hackweek.opensuse.org/21/projects/extend-k3s-ansible-support-with-new-functionalities-or-fork-slash-create-new-one)

It never got merged upstream because the project seems no longer actively maintained.

It includes the work done in these 2 branches:

- multiserver-HA-etcd
- SUSE_systems_prereqs

HA multiserver deployments with etcd are now supported by specifying the hosts under `[multiserver]` in the `hosts.ini` and the arguments can be passed in the dedicated variable `extra_multiserver_args` independently from the master node. Example of a multiserver HA etcd installation is:

```
[master]

192.168.122.156
```
```
[multiserver]

192.168.122.174

192.168.122.120
```
and

`extra_server_args: "--cluster-init"`

In `inventory/sample/group_vars/all.yml`

The prerequisites for *SUSE systems has been added, now the installation of k3s is supported without disabling firewalld which makes it more suitable for production environment.
Thanks to the k3s-on-prem https://github.com/digitalis-io/k3s-on-prem-production/tree/main/roles/k3s-dependencies for the inspiration some pieces of code have been reused here.

Firewalld config and rules are removed when `reset.yml` is run. The config will be fully rolled back to its original state.


# Original Main README of the project


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

To get access to your **Kubernetes** cluster just

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config
```
