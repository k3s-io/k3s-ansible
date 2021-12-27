
## Introduction

`inventory/x/group_vars/all.yml` is meant to be modified appropriately for your environment.
If you are familiar with installing **k3s** from [https://get.k3s.io/](https://get.k3s.io/),
some install flags have been implemented here.

ansible variables that were previously here have moved to `playbook/group_vars/all.yml`.
Those variables are used within the playbooks and roles are not meant to be changed by a user of **k3s-ansible**.
When adding a new _install_ variable, a corresponding variable is added to `playbook/group_vars/all.yml`
which is then used throughout **k3s-ansible**.

## General flags

- **ansible_user**: specifies the username that has SSH password-less access to configure your hosts.
The default is `debian`.

- **cluster_config**: specifies the location of where to capture the kube config of the new cluster.
The default is `playbook/cluster.conf`.

## High-Availability (HA) Flags

- **ha_enabled**: specifies if the cluster will have an HA embedded database using **etcd**.
The default is `false`.

- **ha_cluster_vip**: specifies the virtual IP (VIP) address in front of the control-plane servers for
agent configuration as well as cluster definition in .kube/config.
Note: This is an IP address different than those of the cluster nodes.
Today, this is a static IP address provided in this file.
It is possible to get an IP address dynamically but that is not implemented here.

- **ha_cluster_method**: specifies the method of clustering to use for the virtual IP.
The methods implemented today are:
1. **external** - requires a load-balancer external to the cluster
2. **kube-vip** - [https://kube-vip.io](https://kube-vip.io), arp-based daemonset using leader election

Other load-balancing options are available (e.g., **keepalived**) but are not implemented here (yet).

### Flags that control the version of k3s downloaded

There are four (4) flags that control which version of **k3s** is installed on your hosts.

- **install_k3s_commit**: specifies the commit of **k3s** to download from temporary cloud storage.
The default is to leave this `undefined` as this flag is for developers and QA use. 

- **install_k3s_version**: specifies the version of **k3s** to download from Github.
If undefined (the default), ansible will attempt to download from a channel.

- **install_k3s_channel_url**: specifies the URL for the channels.
The default is [https://update.k3s.io/v1-release/channels](https://update.k3s.io/v1-release/channels)
It is not something typically changed but is implemented for completeness sake.

- **install_k3s_channel**: specifies the channel from which to get the version.
The default is the `stable` channel.  A typical channel used is `latest`.

### Flags that change the location of binaries and data

There are three (3) flags that change the default location of files.

- **install_k3s_bin_dir**: specifies the directory to install the **k3s** binary and links.
The default is `/usr/local/bin`.

- **install_k3s_systemd_dir**: specifies the directory to install **systemd**
service and environment files.  The default is `/etc/systemd/system`.

- **install_k3s_data_dir**: specifies the data director for the **k3s** service.
This defaults to `/var/lib/rancher/k3s` and is not (yet) a flag in **k3s-io/k3s**.

### Flags for the k3s executable

The install script from [https://get.k3s.io/](https://get.k3s.io/) has one flag to
provide extra arguments to the **k3s** executable.  **k3s-ansible** uses two flags,
one for the server and one for the agent(s).  These are:

- **install_k3s_server_args**: Default is ''.
- **install_k3s_agent_args**: Default is ''.


## Other flags that were considered from [https://get.k3s.io/](https://get.k3s.io/)

### Flags not yet implemented

The flags that have yet to be implemented are:

- install_k3s_skip_selinux_rpm:  If set to true, ansible will skip automatic installation of the **k3s** RPM.
- install_k3s_selinux_warn:  If set to true, ansible will continue if the **k3s-selinux** policy is not found.
- install_k3s_name: specifies the name of systemd service to create.
- install_k3s_type: specifies the type of systemd service to create.

### Flags that will not be implemented

Lastly, some flags did not make sense to implement with **k3s-ansible**:

- install_k3s_skip_download:  k3s-ansible always downloads the **k3s** binary and its hash.
- install_k3s_force_restart:  k3s-ansible always restarts the service.
- install_k3s_skip_enable:  k3s-ansible always enables the service.
- install_k3s_skip_start:   k3s-ansible always starts the service.

