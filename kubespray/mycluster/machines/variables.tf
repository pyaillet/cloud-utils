variable "gce_region" {
  type    = "string"
  default = "europe-west4"
}

variable "gce_zone" {
  type = "string"
  default = "europe-west4-a"
}

variable "gce_ssh_user" {
  type = "string"
  default = "ubuntu"
}

variable "gce_ssh_pub_key_file" {
  type = "string"
  default = "kube-rsa.pub"
}
