
# public subnet in AZ 1
resource "aws_subnet" "public_subnet_AZ1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_AZ1_cidr_block
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}_public_subnet_AZ1"
    env  = "${var.environment}"
  }
}

# public subnet in AZ 2
resource "aws_subnet" "public_subnet_AZ2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_AZ2_cidr_block
  availability_zone       =  var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}_public_subnet_AZ2"
    env  = "${var.environment}"
  }
}



# private subnets in AZ 1
resource "aws_subnet" "private_app_subnet_AZ1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_app_subnet_AZ1_cidr_block
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.environment}_private_app_subnet_AZ1"
    env  = "${var.environment}"
  }
}

resource "aws_subnet" "private_data_subnet_AZ1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_data_subnet_AZ1_cidr_block
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.environment}_private_data_subnet_AZ1"
    env  = "${var.environment}"
  }
}

# private subnets in AZ 2
resource "aws_subnet" "private_app_subnet_AZ2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_app_subnet_AZ2_cidr_block
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.environment}_private_app_subnet_AZ2"
    env  = "${var.environment}"
  }
}

resource "aws_subnet" "private_data_subnet_AZ2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_data_subnet_AZ2_cidr_block
  availability_zone =  var.availability_zones[1]

  tags = {
    Name = "${var.environment}_private_data_subnet_AZ2"
    env  = "${var.environment}"
  }
}