# SCS Instructions

These instructions will result in a k3s cluster on 3 virtual machines created by the NetApp Shared Compute Service (SCS).  This is a multi-step process that has the possibility to be automated.  However, this solution is only intended to serve a short term goal until the Containers As A Service (CaaS) is ready to fully support the needs of the dev team.

## Steps

- Create 3 SCS machines

> These need to be t2.small (2CPU with 6GB RAM) running Debian 10.

- Once SCS notifies you the machines are ready, you'll need to `ssh-copy-key` to all of the nodes.

- Follow the instructions in the in the [README](./README.md) in this project.

- If you don't already have ansible running on your laptop, you'll need to install a python virtualenv.

```bash
virtualenv py3 --python=$(which python3)
source py3/bin/activate
pip install ansible
```

- Edit the IP addresses in the [SCS inventory.](./inventory/scs/hosts.ini) . Also note the `./inventory/scs/group_vars/all.yml` contains the OS user who can ssh directly to the node as a result of the `ssh-copy-key` operation.  The default for SCS is root but if for some reason it is different, this is the file to update.

- Run `ansible-playbook site.yml -i inventory/scs/hosts.ini`.  This will take about 2 minutes to complete.

- Run `scp root@<cp-node-ip>:~/.kube/config ./kubeconfig` to copy the k8s config file locally.

- Export the _KUBECONFIG_ environment variable or otherwise make `kubectl` understand you want to work with this cluster.
