#!/bin/bash

ZONE=europe-west4-a

# Bootstrap first master
host=master-0
gcloud compute scp --ssh-key-file kube-rsa kubeadm-config-0.yaml $host:~ --zone $ZONE

echo "Bootstrapping first node..."
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm init --config kubeadm-config-0.yaml"

echo "Gathering generated conf and certs..."
mkdir -p bootstrap
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo tar cjvf kubernetes.tar.bz2 /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key /etc/kubernetes/pki/sa.key /etc/kubernetes/pki/sa.pub /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.key /etc/kubernetes/admin.conf"
gcloud compute scp --ssh-key-file kube-rsa $host:~/kubernetes.tar.bz2 bootstrap/kubernetes.tar.bz2 --zone $ZONE

gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo mkdir -p /root/.kube && sudo cp /etc/kubernetes/admin.conf /root/.kube/config"
