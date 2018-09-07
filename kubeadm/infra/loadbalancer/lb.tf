variable "gce_region" {
  type    = "string"
  default = "europe-west1"
}

variable "gce_zone" {
  type = "string"
  default = "europe-west1-c"
}

data "google_compute_instance_group" "master-group" {
    name = "master-group"
    zone = "${var.gce_zone}"
}

data "google_compute_global_address" "api-server-front" {
  name = "api-server-front"
}

resource "google_compute_firewall" "allow-api-server" {
  name    = "allow-api-server"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_target_tcp_proxy" "api-server-proxy" {
  name = "api-server-proxy"
  backend_service = "${google_compute_backend_service.api-server-service.self_link}"
}

resource "google_compute_backend_service" "api-server-service" {
  name        = "api-server-service"
  port_name   = "api-server"
  protocol    = "TCP"
  timeout_sec = 10

  health_checks = ["${google_compute_health_check.api-server-healthcheck.self_link}"]
  
  backend {
    group = "${data.google_compute_instance_group.master-group.self_link}"
  }
}

resource "google_compute_health_check" "api-server-healthcheck" {
  name = "default"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "6443"
  }
}

resource "google_compute_global_forwarding_rule" "api-server-forwarding-rule" {
  name       = "api-server-forwarding-rule"
  target     = "${google_compute_target_tcp_proxy.api-server-proxy.self_link}"
  ip_address = "${data.google_compute_global_address.api-server-front.address}"
  port_range = "443"
}
