output "aws_internet_gateway" {
  value = aws_internet_gateway.igw
}

output "nat_gateway_AZ1" {
  value = aws_nat_gateway.nat_gateway_AZ1
}

output "nat_gateway_AZ2" {
   value = aws_nat_gateway.nat_gateway_AZ2
}

output "alb_security_group" {
  value = aws_security_group.alb_security_group
}

output "ssh_security_group" {
  value = aws_security_group.ssh_security_group
}

output "webserver_security_group" {
  value = aws_security_group.webserver_security_group
}

output "database_security_group" {
  value = aws_security_group.database_security_group
}
output "efs_security_group" {
  value = aws_security_group.efs_security_group
}
// subnet
output "public_subnet_AZ1" {
  value = aws_subnet.public_subnet_AZ1
}

output "public_subnet_AZ2" {
  value = aws_subnet.public_subnet_AZ2
}

output "private_app_subnet_AZ1" {
  value = aws_subnet.private_app_subnet_AZ1
}

output "private_data_subnet_AZ1" {
  value = aws_subnet.private_data_subnet_AZ1
}

output "private_app_subnet_AZ2" {
  value = aws_subnet.private_app_subnet_AZ2
}
output "private_data_subnet_AZ2" {
  value = aws_subnet.private_data_subnet_AZ2
}

output "vpc" {
  value = aws_vpc.vpc
}