#!/bin/bash
USER=pierre_yves_aillet

sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose
sudo usermod -aG docker $USER

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

curl -LO https://github.com/kubernetes/minikube/releases/download/v0.27.0/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

cat <<EOF >/home/$USER/deploy-minikube.sh
#!/bin/bash
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=\$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir \$HOME/.kube || true
touch \$HOME/.kube/config

export KUBECONFIG=\$HOME/.kube/config

sudo -E minikube start --bootstrapper localkube --vm-driver=none
EOF
chmod +x deploy-minikube.sh
