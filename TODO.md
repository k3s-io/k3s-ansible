# Update

Author: [https://github.com/jon-stumpf](https://github.com/jon-stumpf)

I came across *k3s-ansible* looking for an easy why to create a highly-available cluster
on my [Turing Pi 1](https://turingpi.com/v1/).
I saw *k3s-ansible* could easily configure my hosts but was missing the HA component.
Further research led me to the [k3s-ha](https://github.com/k3s-io/k3s-ansible/tree/k3s-ha)
branch but found that it still was incomplete for my needs.
In developing the needed additions, I discovered issues in the
[master](https://github.com/k3s-io/k3s-ansible/tree/master) branch and spent a month
reviewing the yaml files of *k3s-ansible* and the shell scripts from
[https://get.k3s.io](https://get.k3s.io).
In the end, I brought *k3s-ansible* to be at near parity with *https://get.k3s.io* and
I believe I have addressed some open issues in
[my pull requests](https://github.com/k3s-io/k3s-ansible/pulls/jon-stumpf).

Once I completed my changes to the *master* branch, I got back to work on *k3s-ha*.
Building on the
[work of St0rmingBr4in](https://github.com/k3s-io/k3s-ansible/commits?author=St0rmingBr4in),
I implemented the HA embedded database using *etcd* and three cluster VIP methods:
1. **external**: uses an externally provided cluster VIP
2. **kube-vip**: uses [kube-vip](https://kube-vip.io/) with arp arbitration
3. **keepalived**: uses [keepalived](https://www.redhat.com/sysadmin/keepalived-basics) to implement VRRP

I have reached out to
[itwars](https://github.com/itwars) and
[St0rmingBr4in](https://github.com/St0rmingBr4in) to get their feedback on this work and
to collaborate on closing the open issues and pull requests.
In the meantime, I would like others to provide feedback on my
[k3s-ha](https://github.com/jon-stumpf/k3s-ansible/tree/k3s-ha).
This is now stable and incorporates all my work on *k3s-ansible* except for a few commits.
Please, try it out.

# TODO

1. Make all roles *idempotent* and not report changes when none, in fact, are needed or material.
2. Add *keepalived*' label to servers when using keepalived;  Add the following annotations:
  - `keepalived/vrrp_instance=<name>`
  - `keepalived/master=[true|false]`
  - `keepalived/version=<version>`
  - `keepalived/vip=<ipaddr>/<cidr>`
3. Add the ability to download the latest version of *kube-vip*
  - Currently, uses a static version (v0.4.0) that can be manually changed
4. Make sure all roles have defaults defined
5. Make HA not require `k3s_token` to be defined
  - i.e., use the `node-token` from the first server
6. Replace `command` and `shell` tasks with *ansible* equivalents (where appropriate)
  - `ip`
  - `kubectl`
  - etc.
7. Is the `raspberrypi` role a NO-OP?
  - It does not appear to execute any tasks that induce change
  - Should it be deleted?
8. From where does *k3s-selinux* get installed?
  - The `reset/download` role deletes it.

# Progress Report

| Role                  | Role Type  | Idempotent         | Only Real Changes  | TODOs | BUGs |
| :-------------------- | :--------: | :---: | :---: | :---: | :---: |
| cluster-config        | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| config-check          | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| prereq                | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| download              | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| raspberrypi           | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| ha/etcd               | HA-only    |  | unknown | | |
| ha/keepalived         | HA-only    | :heavy_check_mark: | :heavy_check_mark: | | |
| ha/kube-vip           | HA-only    | :heavy_check_mark: | :heavy_check_mark: | | |
| k3s/server            | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| k3s/agent             | install    | :heavy_check_mark: | :heavy_check_mark: | | |
| reset/download        | uninstall  | :heavy_check_mark: | :heavy_check_mark: | | |
| reset/ha/keepalived   | uninstall  | :heavy_check_mark: | :heavy_check_mark: | | |
| reset/ha/kube-vip     | uninstall  | :heavy_check_mark: | :heavy_check_mark: | | |
| reset/k3s             | uninstall  | :heavy_check_mark: | :heavy_check_mark: | | |

