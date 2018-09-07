resource "google_compute_instance" "master" {
  count    = 3
  name     = "master-${count.index}"
  machine_type    = "n1-standard-1"
  zone            = "${var.gce_zone}"
  can_ip_forward  = true

  tags = ["kubeadm","master"]
  
  scheduling {
  	preemptible         = true
    automatic_restart   = false
  }
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.kubeadm-network-sub0.self_link}"
    address = "10.240.0.1${count.index}"

    access_config {
      // Ephemeral IP
    }
  }
  
  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }
  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
  metadata_startup_script = <<FOO
#!/bin/bash
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
   edge"
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose
sudo usermod -aG docker ubuntu
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
FOO
}

resource "google_compute_instance_group" "master_group" {
  name               = "master-group"
  zone               = "${var.gce_zone}"
  instances          = ["${google_compute_instance.master.0.self_link}"]
  named_port {
  	name = "api-server"
  	port = 6443
  }
}