resource "google_compute_network" "kubeadm-network" {
  name                    = "kubeadm-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "kubeadm-network-sub0" {
  name          = "kubeadm-network-sub0"
  region		= "${var.gce_region}"
  network       = "${google_compute_network.kubeadm-network.name}"
  ip_cidr_range = "10.240.0.0/20"
}

resource "google_compute_firewall" "internal" {
  name    = "kubeadm-network--allow-internal"
  network = "${google_compute_network.kubeadm-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.240.0.0/20", "10.200.0.0/16"]
}

resource "google_compute_firewall" "external" {
  name    = "kubeadm-network--allow-external"
  network = "${google_compute_network.kubeadm-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}