#!/bin/bash

virtualenv venv
. venv/bin/activate
pip install ansible
cd /project
ansible-playbook playbooks/site.yml -i dnd/inventory.yml
