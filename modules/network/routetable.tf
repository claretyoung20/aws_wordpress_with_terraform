
# Route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.public_route_table_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}_public_route_table"
    env  = "${var.environment}"
  }
}

# associate route table to public subnet to give it internet access
resource "aws_route_table_association" "route_table_association_AZ1" {
  subnet_id      = aws_subnet.public_subnet_AZ1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "route_table_association_AZ2" {
  subnet_id      = aws_subnet.public_subnet_AZ2.id
  route_table_id = aws_route_table.public_route_table.id
}



# create new private route table to route traffic to private subnets through nat gateway
# Route table AZ1
resource "aws_route_table" "private_route_table_AZ1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.public_cidr_block
    nat_gateway_id = aws_nat_gateway.nat_gateway_AZ1.id
  }

  tags = {
    Name = "${var.environment}_private_route_table_AZ1"
    env  = "${var.environment}"
  }
}


# Route table AZ2
resource "aws_route_table" "private_route_table_AZ2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.public_cidr_block
    nat_gateway_id = aws_nat_gateway.nat_gateway_AZ2.id
  }

  tags = {
    Name = "${var.environment}_private_route_table_AZ2"
    env  = "${var.environment}"
  }
}

# associate route table to private subnet to give it internet access
## AZ1
### app
resource "aws_route_table_association" "private_route_table_association_app_AZ1" {
  subnet_id      = aws_subnet.private_app_subnet_AZ1.id
  route_table_id = aws_route_table.private_route_table_AZ1.id
}
### data
resource "aws_route_table_association" "private_route_table_association_data_AZ1" {
  subnet_id      = aws_subnet.private_data_subnet_AZ1.id
  route_table_id = aws_route_table.private_route_table_AZ1.id
}

## AZ2
### app
resource "aws_route_table_association" "private_route_table_association_app_AZ2" {
  subnet_id      = aws_subnet.private_app_subnet_AZ2.id
  route_table_id = aws_route_table.private_route_table_AZ2.id
}

## AZ2
### data
resource "aws_route_table_association" "private_route_table_association_data_AZ2" {
  subnet_id      = aws_subnet.private_data_subnet_AZ2.id
  route_table_id = aws_route_table.private_route_table_AZ2.id
}
