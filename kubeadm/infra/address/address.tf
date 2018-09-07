resource "google_compute_global_address" "api-server-front" {
  name = "api-server-front"
}

output "ip" {
  value = "${google_compute_global_address.api-server-front.address}"
}