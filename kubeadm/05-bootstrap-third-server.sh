#!/bin/sh

ZONE=europe-west4-a
host=master-2
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE kubeadm-config-2.yaml $host:~/kubeadm-config-2.yaml
gcloud compute scp --ssh-key-file kube-rsa --zone $ZONE ./bootstrap-master-2.sh $host:~/bootstrap-master-2.sh

# gcloud compute ssh --ssh-key-file kube-rsa --zone $ZONE $host
## kubelet
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo ./bootstrap-master-2.sh"
