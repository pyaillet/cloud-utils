resource "google_compute_instance" "worker" {
  count = 4
  name            = "worker-${count.index}"
  machine_type    = "n1-standard-1"
  zone            = "${var.gce_zone}"
  can_ip_forward  = true

  tags = ["kubespray","worker"]
  
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
    subnetwork = "${google_compute_subnetwork.kubespray-network-sub0.self_link}"
    address = "10.240.0.2${count.index}"

    access_config {
      // Ephemeral IP
    }
  }
  
  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    startup-script = <<SCRIPT
	apt-get update
	apt-get install -y python-pip
SCRIPT
  }
}

resource "google_compute_instance_group" "worker_group" {
  name               = "worker-group"
  zone               = "${var.gce_zone}"
  instances          = ["${google_compute_instance.worker.*.self_link}"]
}
