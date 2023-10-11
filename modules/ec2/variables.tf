variable "environment" {}

variable "public_key" {}

variable "custom_ami_id" {}

variable "web_server_groups" {
  type = list(string)
}