#!/bin/bash

git clone https://github.com/kubernetes-incubator/kubespray.git
cd kubespray

# Install dependencies from ``requirements.txt``
sudo pip install -r /home/ubuntu/kubespray/requirements.txt

mkdir -p inventory/mycluster

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample/* inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(10.240.0.10 10.240.0.11 10.240.0.20 10.240.0.21 10.240.0.22 10.240.0.23)
CONFIG_FILE=inventory/mycluster/hosts.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}

ansible-playbook -i inventory/mycluster/hosts.ini cluster.yml -b -v \
  --private-key=~/.ssh/kube-rsa
