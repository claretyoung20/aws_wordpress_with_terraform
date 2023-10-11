variable "environment" {}

variable "private_data_subnet_AZ1_id" {}

variable "private_data_subnet_AZ2_id" {}

variable "efs_sec_groups" {
  type = list(string)
}