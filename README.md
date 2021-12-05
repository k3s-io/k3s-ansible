# Build a Kubernetes cluster using k3s via Ansible

Author: <https://github.com/itwars>

## K3s Ansible Playbook

Build a Kubernetes cluster using Ansible with k3s.  The goal is easily install a Kubernetes cluster
on machines running:

- [X] Debian
- [X] Ubuntu
- [X] CentOS

on processor architecture:

- [X] x64
- [X] arm64
- [X] armhf

## System requirements

Deployment environment must have Ansible 2.4.0+.
Server and Agent nodes must have passwordless SSH access.

## Usage

First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above.
For example:

```bash
[server]
192.16.35.12

[agent]
192.16.35.[10:11]

[k3s_cluster:children]
server
agent
```

If multiple hosts are in the server group and HA is enabled, the playbook will automatically
setup high availability with an embedded database (etcd).  This requires at least k3s version
v1.19.5+k3s1.  See https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/.

You must set `ha_enabled` to **true** in `inventory/my-cluster/group_vars/all.yml`.  HA expects
that there is a cluster virtual IP (`ha_lb_vip`) in front of the control-plane servers.  And,
there are multiple methods supported to implement the cluster VIP.

Edit the remaining variables in this file to best match your environment.

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

## Kubeconfig

A copy of your cluster's config will be put in `./cluster.config`.  Copy this into your `~/.kube/config`
to get access to your new **k3s** cluster.

