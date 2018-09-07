#!/bin/sh

kubeadm alpha phase certs all --config kubeadm-config-1.yaml
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-config-1.yaml
kubeadm alpha phase kubelet write-env-file --config kubeadm-config-1.yaml
kubeadm alpha phase kubeconfig kubelet --config kubeadm-config-1.yaml
systemctl start kubelet

## etcd

export CP0_IP=10.240.0.10
export CP0_HOSTNAME=master-0
export CP1_IP=10.240.0.11
export CP1_HOSTNAME=master-1

export KUBECONFIG=/etc/kubernetes/admin.conf 
kubectl exec -n kube-system etcd-${CP0_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP0_IP}:2379 member add ${CP1_HOSTNAME} https://${CP1_IP}:2380
kubeadm alpha phase etcd local --config kubeadm-config-1.yaml

## deploy and start the control plane components
kubeadm alpha phase kubeconfig all --config kubeadm-config-1.yaml
kubeadm alpha phase controlplane all --config kubeadm-config-1.yaml
kubeadm alpha phase mark-master --config kubeadm-config-1.yaml
