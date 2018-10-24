#!/bin/sh

ZONE=europe-west4-a

host=master-0
FRONT_LB=$(terraform output -state=address.tfstate ip)
CA_CERT_HASH=sha256:$(gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")
TOKEN=$(gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm  token list | tail -n 1 | head -n 1 | cut -d' ' -f1")
echo "Front lb address: $FRONT_LB"
echo "CA Cert hash: $CA_CERT_HASH"
echo "Token: $TOKEN"
WORKERS="worker-0 worker-1 worker-2"
for host in ${WORKERS}; do
	gcloud compute ssh --ssh-key-file kube-rsa $host --zone $ZONE --command "sudo kubeadm join $FRONT_LB:443 --token $TOKEN --discovery-token-ca-cert-hash $CA_CERT_HASH"
done
