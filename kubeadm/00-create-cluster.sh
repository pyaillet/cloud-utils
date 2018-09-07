#!/bin/bash

ZONE=europe-west1-c

# Create api-server load balancer front address
./infra/address/create.sh

# Create machines
ssh-keygen -f kube-rsa

terraform apply ./infra/machines/

host=master-0
gcloud compute ssh $host --zone $ZONE --command "mkdir -p .ssh"
gcloud compute scp kube-rsa $host:~/.ssh/id_rsa --zone $ZONE
gcloud compute scp kube-rsa.pub $host:~/.ssh/id_rsa.pub --zone $ZONE

# Bootstrap first master
host=master-0
gcloud compute scp --ssh-key-file kube-rsa kubeadm-config-0.yaml $host --zone $ZONE
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm init kubeadm-config-0.yaml"

mkdir -p bootstrap
USER=root
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo tar cjvf kubernetes.tar.bz2 /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key /etc/kubernetes/pki/sa.key /etc/kubernetes/pki/sa.pub /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.key /etc/kubernetes/admin.conf"
gcloud compute scp --ssh-key-file kube-rsa $host:~/kubernetes.tar.bz2 bootstrap/kubernetes.tar.bz2 --zone $ZONE

# Prepare the other masters
CONTROL_PLANE_IPS="master-1 master-2"
for host in ${CONTROL_PLANE_IPS}; do
    gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE bootstrap/kubernetes.tar.bz2 $host:~/kubernetes.tar.bz2
    gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "cd / && sudo tar xjf ~/kubernetes.tar.bz2"
done

# Add second server
host=master-1
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE kubeadm-config-1.yaml $host:~/kubeadm-config-1.yaml

## kubelet
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase certs all --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase kubelet write-env-file --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase kubeconfig kubelet --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo systemctl start kubelet"

## etcd

export CP0_IP=10.132.0.10
export CP0_HOSTNAME=master-0
export CP1_IP=10.132.0.11
export CP1_HOSTNAME=master-1

export KUBECONFIG=/etc/kubernetes/admin.conf 
kubectl exec -n kube-system etcd-${CP0_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP0_IP}:2379 member add ${CP1_HOSTNAME} https://${CP1_IP}:2380
kubeadm alpha phase etcd local --config kubeadm-config-1.yaml

## deploy and start the control plane components
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase kubeconfig all --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase controlplane all --config kubeadm-config-1.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm alpha phase mark-master --config kubeadm-config-1.yaml"

# Add third server
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE kubeadm-config-2.yaml master-2:~/kubeadm-config-2.yaml


# Install network
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml