#!/bin/bash

REGION=europe-west4
ZONE=europe-west4-a

# Create api-server load balancer front address
terraform apply -auto-approve -state=address.tfstate -var gce_region=$REGION -var gce_zone=$ZONE ./infra/address/

# Create machines
if [[ ! -f kube-rsa ]]; then
	ssh-keygen -f kube-rsa
fi

terraform apply -auto-approve -state=machines.tfstate -var gce_region=$REGION -var gce_zone=$ZONE ./infra/machines/

for i in $(seq 0 2); do
	sed -e "s/{{LB_IP_ADDRESS}}/$(terraform output -state=address.tfstate ip)/" kubeadm-config-$i.yaml.tmpl > kubeadm-config-$i.yaml
done

echo "Creating lb..."
terraform apply -auto-approve -state=lb.tfstate -var gce_region=$REGION -var gce_zone=$ZONE ./infra/loadbalancer/
