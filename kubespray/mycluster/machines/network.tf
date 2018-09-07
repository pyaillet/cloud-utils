resource "google_compute_network" "kubespray-network" {
  name                    = "kubespray-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "kubespray-network-sub0" {
  name          = "kubespray-network-sub0"
  region		= "${var.gce_region}"
  network       = "${google_compute_network.kubespray-network.name}"
  ip_cidr_range = "10.240.0.0/20"
}

resource "google_compute_firewall" "internal" {
  name    = "kubespray-network--allow-internal"
  network = "${google_compute_network.kubespray-network.name}"

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
  name    = "kubespray-network--allow-external"
  network = "${google_compute_network.kubespray-network.name}"

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
