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

- Deployment environment must have Ansible 2.4.0+
- Master and nodes must have passwordless SSH access
- For an airgap installation (no outbound internet access on nodes), all asset files for your CPU architecture from `https://github.com/k3s-io/k3s/releases/tag/{k3s_version}` should reside on an HTTP share within your private environment, accessible by all target nodes. For some super quick ways to to share a folder via HTTP, check out [this post](https://unix.stackexchange.com/questions/32182/simple-command-line-http-server). Any ordinary HTTP server will work as well.

    Example content for the HTTP folder when choosing the `amd64` architecture and k3s version `v1.20.2+k3s1` (notice the subfolder set to the version name):
    - `v1.20.2+k3s1` (the subfolder containing the assets below)
    - `v1.20.2+k3s1/k3s`
    - `v1.20.2+k3s1/k3s-airgap-images-amd64.tar`
    - `v1.20.2+k3s1/sha256sum-amd64.txt`

    For `arm64` respectively:
    - `v1.20.2+k3s1` (the subfolder containing the assets below)
    - `v1.20.2+k3s1/k3s-arm64`
    - `v1.20.2+k3s1/k3s-airgap-images-arm64.tar`
    - `v1.20.2+k3s1/sha256sum-arm64.txt`

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

If needed, you can also edit `inventory/my-cluster/group_vars/all.yml` to match your environment. For an airgap installation (see requirements above), please edit `remote_repo_url` to point to your webserver root *containing* the k3s version *subfolder*, e.g. `http://internalurlorip/k3s-binaries-and-images`. Don't point this directly to the version subfolder itself (-> point it to the *parent* folder), and don't include a trailing `/`.

Start provisioning of the cluster using the following command:

```bash
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini
```

## Kubeconfig

To get access to your **Kubernetes** cluster just

```bash
scp debian@master_ip:~/.kube/config ~/.kube/config
```
