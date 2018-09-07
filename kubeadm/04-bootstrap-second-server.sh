#!/bin/sh

ZONE=europe-west4-a
host=master-1
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE kubeadm-config-1.yaml $host:~/kubeadm-config-1.yaml
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE bootstrap-master-1.sh $host:~/bootstrap-master-1.sh

# gcloud compute ssh --ssh-key-file kube-rsa --zone $ZONE $host
## kubelet
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo ./bootstrap-master-1.sh"
