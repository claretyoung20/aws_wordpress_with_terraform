variable "environment" {}

variable "db_name" {}
variable "db_username" {}

variable "db_password" {}

variable "subnet_ids" {
  type = list(string)
}

variable "availability_zone" {}

variable "vpc_security_group_ids" {
  type    = list(string)
}