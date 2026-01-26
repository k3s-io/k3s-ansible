# mattykay/k3s-ansible 

[![Sync & Publish Status](https://github.com/mattykay/k3s-ansible/actions/workflows/sync-and-publish.yml/badge.svg)](https://github.com/mattykay/k3s-ansible/actions)
[![Galaxy Version](https://img.shields.io/ansible/v/mattykay/k3s_ansible?label=Galaxy%20Collection)](https://galaxy.ansible.com/ui/repo/published/mattykay/k3s_ansible/)

This repository is a maintained fork of the [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible). 

### Why this fork exists:
* **Automated Releases:** Automatically packaged and published to Ansible Galaxy (since they don't as per [this](https://github.com/k3s-io/k3s-ansible/issues/316#issuecomment-2030389486))
* **Semantic Versioning:** Auto-calculated versioning based on commit history (best effort since not all upstream commits confirm to semver)
* **Continuous Sync:** Stays up-to-date with upstream changes via daily automated merges.

---

## Installation

To use this specific fork, install it via Ansible Galaxy using this namespace:

```bash
ansible-galaxy collection install mattykay.k3s_ansible
```