#!/bin/bash

ZONE=europe-west4-a

# Prepare the other masters
CONTROL_PLANE_IPS="master-1 master-2"
for host in ${CONTROL_PLANE_IPS}; do
    gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE bootstrap/kubernetes.tar.bz2 $host:~/kubernetes.tar.bz2
    gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "cd / && sudo tar xjf ~/kubernetes.tar.bz2"
done