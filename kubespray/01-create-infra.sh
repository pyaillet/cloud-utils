#!/bin/sh

REGION="europe-west4"
ZONE="europe-west4-a"

if [ ! -f kube-rsa ]; then
       ssh-keygen -f kube-rsa -N ""
fi       

terraform init mycluster/machines
terraform apply -auto-approve \
    -var "gce_zone=$ZONE" \
    -var "gce_region=$REGION" \
    mycluster/machines

gcloud compute ssh --ssh-key-file kube-rsa ubuntu@bastion --command "mkdir -p ~/.ssh" --zone $ZONE
gcloud compute scp --ssh-key-file kube-rsa kube-rsa ubuntu@bastion:~/.ssh/ --zone $ZONE
gcloud compute scp --ssh-key-file kube-rsa kube-rsa.pub ubuntu@bastion:~/.ssh/ --zone $ZONE
gcloud compute scp --ssh-key-file kube-rsa create-cluster.sh ubuntu@bastion:~ --zone $ZONE
gcloud compute ssh --ssh-key-file kube-rsa ubuntu@bastion --command "./create-cluster.sh" --zone $ZONE
