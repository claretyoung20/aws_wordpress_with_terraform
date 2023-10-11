variable "environment" {}
variable "availability_zones" {
  type    = list(string)
}

variable "vpc_cidr_block" {}

variable "public_subnet_AZ1_cidr_block" {}

variable "public_subnet_AZ2_cidr_block" {}

variable "public_route_table_cidr_block" {}

variable "private_app_subnet_AZ1_cidr_block" {}

variable "private_data_subnet_AZ1_cidr_block" {}

variable "private_app_subnet_AZ2_cidr_block" {}

variable "private_data_subnet_AZ2_cidr_block" {}

variable "public_cidr_block" {}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "public_key" {}

variable "my_ip" { 
  # enter your ip address
}

variable "custom_ami_id" {}

variable "domain_name" {}

variable "domain_alt_name" {}

