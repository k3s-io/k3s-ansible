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
Server and agent nodes must have passwordless SSH access

## Usage

First create a new directory based on the `sample` directory within the `inventory` directory:

```bash
cp -R inventory/sample inventory/my-cluster
```

Second, edit `inventory/my-cluster/hosts.ini` to match the system information gathered above. For example:

```bash
[server]
192.16.35.12

[agent]
192.16.35.[10:11]

[k3s_cluster:children]
server
agent
```

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment.

### Control Plane High Availability

If multiple hosts are in the server group, the playbook will automatically setup k3s in HA mode with etcd.
https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/
This requires at least k3s version 1.19.1

To configure fail-over for the k3s server api add the following to your `inventory/my-cluster/group_vars/all.yml`

```yaml
apiserver_endpoint: 192.168.30.10  # update this to a non-cluster ip address

keepalived_enabled: true
```

See `inventory/sample-ha` for a sample high availability control plane configuration.

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

## Kubeconfig

To get access to your **Kubernetes** cluster just

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config
```
