
# Introduction

`inventory/x/group_vars/all.yml` is meant to be modified appropriately for your environment.

*ansible* variables that were previously here have moved to `playbook/group_vars/all.yml`.
Those variables are used within the playbooks and roles are not meant to be changed by a user of *k3s-ansible*.
When adding a new _install_ variable, a corresponding variable is added to `playbook/group_vars/all.yml`
which is then used throughout *k3s-ansible*.

## General Variables

- **ansible_user**: specifies the username that has *ssh* password-less access to configure your hosts.
The default is `debian`.

- **cluster_config**: specifies the location of where to capture the kube configuration file for the new cluster.
The default is `playbook/cluster.conf`.

## High-Availability (HA) Variables

- **ha_enabled**: specifies if the cluster will have an HA embedded database using *etcd*.
The default is `false`.

- **ha_cluster_vip**: specifies the virtual IP (VIP) address in front of the control-plane servers for
agent configuration as well as cluster definition in `.kube/config`.
Note: This is an IP address different than those of the cluster nodes.
Today, this is a static IP address provided in this file.
It is possible to get an IP address dynamically but that is not implemented here.

- **ha_cluster_method**: specifies the method of clustering to use for the virtual IP.
The methods implemented today are:
  1. `external` - requires a load-balancer external to the cluster
  2. `kube-vip` - [https://kube-vip.io](https://kube-vip.io), arp-based daemonset using leader election
  3. `keepalived` - all *k3s* servers are configured with [keepalived](https://www.redhat.com/sysadmin/keepalived-basics) to manage a VRRP instance

## Install Variables

If you have installed *k3s* from [https://get.k3s.io](https://get.k3s.io), these variables will be familiar.
*Install* variables are meant to duplicate the install flags and environment variables found in the install script
(see [Installation Options](https://rancher.com/docs/k3s/latest/en/installation/install-options/#options-for-installation-with-script)).
Each variable has a prefix of `install_` and implements, to the extent possible, the actions of the shell script as documented below.

### Variables that control the version of *k3s* downloaded

There are four (4) variables that control which version of *k3s* is installed on your hosts.

- **install_k3s_commit**: specifies the commit of *k3s* to download from temporary cloud storage.
The default is to leave this `undefined` as this variable is for developers and QA use. 

- **install_k3s_version**: specifies the version of *k3s* to download from Github.
If left `undefined` (the default), *ansible* will attempt to download from a channel.

- **install_k3s_channel_url**: specifies the URL for the channels.
The default is [https://update.k3s.io/v1-release/channels](https://update.k3s.io/v1-release/channels).
It is not something typically changed but is implemented for completeness sake.

- **install_k3s_channel**: specifies the channel from which to get the version.
The default is the `stable` channel.  A typical channel used is `latest`.

### Variables that change the location of binaries and data

There are three (3) variables that change the default location of files.

- **install_k3s_bin_dir**: specifies the directory to install the *k3s* binary and links.
The default is `/usr/local/bin`.

- **install_k3s_systemd_dir**: specifies the directory to install *systemd*
service and environment files.  The default is `/etc/systemd/system`.

- **install_k3s_data_dir**: specifies the data directory for the *k3s* service.
This defaults to `/var/lib/rancher/k3s`.
Note: this is not (yet) an option in *k3s-io/k3s*.

### Variables for the *k3s* executable

The install script from [https://get.k3s.io/](https://get.k3s.io/) has one flag (**INSTALL_K3S_EXEC**) to
provide extra arguments to the *k3s* executable.  *k3s-ansible* uses two variables:
one for servers and one for agents.  These are:

- **install_k3s_server_args**: the default is `''`.
- **install_k3s_agent_args**: the default is `''`.

### Install Flags not yet implemented

The install flags that have yet to be implemented are:

| Install Flag | What it does |
| :--- | :--- |
| **INSTALL_K3S_SKIP_SELINUX_RPM** | If set to true, *ansible* will skip automatic installation of the *k3s* RPM.
| **INSTALL_K3S_SELINUX_WARN** | If set to true, *ansible* will continue if the *k3s-selinux* policy is not found.
| **INSTALL_K3S_NAME** | specifies the name of *systemd* service to create.
| **INSTALL_K3S_TYPE** | specifies the type of *systemd* service to create.

Currently, nothing will happen if these are set.

### Install Flags that will not be implemented

Lastly, some install flags did not make sense to implement with *k3s-ansible*:

| Install Flag | What *k3s-ansible* does |
| :--- | :--- |
| **INSTALL_K3S_SKIP_DOWNLOAD** | *k3s-ansible* always downloads the *k3s* binary and its hash. |
| **INSTALL_K3S_FORCE_RESTART** | *k3s-ansible* always restarts the service. |
| **INSTALL_K3S_SKIP_ENABLE**   | *k3s-ansible* always enables the service. |
| **INSTALL_K3S_SKIP_START**    | *k3s-ansible* always starts the service. |

