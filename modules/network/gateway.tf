resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}_igw"
    env  = "${var.environment}"
  }
}

# elastic ips for the natgateway
resource "aws_eip" "nat_gateway_eip_AZ1" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}_nat_gateway_eip_AZ1"
    env  = "${var.environment}"
  }
}

resource "aws_eip" "nat_gateway_eip_AZ2" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}_nat_gateway_eip_AZ2"
    env  = "${var.environment}"
  }
}

# create nat gateways in the 2 public subnet to give internet access to the 4 private subnets in 2 AZs
resource "aws_nat_gateway" "nat_gateway_AZ1" {
  allocation_id     = aws_eip.nat_gateway_eip_AZ1.id
  subnet_id         = aws_subnet.public_subnet_AZ1.id
  connectivity_type = "public"

  tags = {
    Name = "${var.environment}_nat_gateway_AZ1"
    env  = "${var.environment}"
  }

}

resource "aws_nat_gateway" "nat_gateway_AZ2" {
  allocation_id     = aws_eip.nat_gateway_eip_AZ2.id
  subnet_id         = aws_subnet.public_subnet_AZ2.id
  connectivity_type = "public"

  tags = {
    Name = "${var.environment}_nat_gateway_AZ2"
    env  = "${var.environment}"
  }

}