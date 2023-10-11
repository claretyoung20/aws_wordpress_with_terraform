variable "environment" {
}

variable "vpc_id" {
  
}

variable "alb_subnets" {
  type = list(string)
}

variable "alb_sec_group" {
  type = list(string)
}

variable "vpc_zone_identifiers" {
  type = list(string)
}
variable "launch_template_id" {}

variable "cert_arn" {}