#!/bin/sh

ZONE=europe-west4-a
host=master-0
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "KUBECONFIG=/etc/kubernetes/admin.conf sudo kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml"
gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "KUBECONFIG=/etc/kubernetes/admin.conf sudo kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml"

