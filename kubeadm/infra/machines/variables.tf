variable "gce_region" {
  type    = "string"
  default = "europe-west1"
}

variable "gce_zone" {
  type = "string"
  default = "europe-west1-c"
}

variable "gce_ssh_user" {
  type = "string"
  default = "ubuntu"
}

variable "gce_ssh_pub_key_file" {
  type = "string"
  default = "kube-rsa.pub"
}