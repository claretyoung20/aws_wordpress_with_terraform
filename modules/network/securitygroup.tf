
# Security groups
# Security Group 1: ALB Security Group
resource "aws_security_group" "alb_security_group" {
  name        = "ALBSecurityGroup"
  description = "Security group for Application Load Balancer (ALB)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr_block]
  }

  tags = {
    Name = "${var.environment}_alb_security_group"
    env  = "${var.environment}"
  }

}

# Security Group 2: SSH Security Group
resource "aws_security_group" "ssh_security_group" {
  name        = "SSHSecurityGroup"
  description = "Security group for SSH access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr_block]
  }


  tags = {
    Name = "${var.environment}_ssh_security_group"
    env  = "${var.environment}"
  }

}

# Security Group 3: Webserver Security Group
resource "aws_security_group" "webserver_security_group" {
  name        = "WebserverSecurityGroup"
  description = "Security group for webservers"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr_block]
  }


  tags = {
    Name = "${var.environment}_webserver_security_group"
    env  = "${var.environment}"
  }
}

# Security Group 4: Database Security Group
resource "aws_security_group" "database_security_group" {
  name        = "DatabaseSecurityGroup"
  description = "Security group for database access"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr_block]
  }


  tags = {
    Name = "${var.environment}_database_security_group"
    env  = "${var.environment}"
  }
}

# Security Group 5: EFS Security Group
resource "aws_security_group" "efs_security_group" {
  name        = "EFSSecurityGroup"
  description = "Security group for Amazon EFS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_security_group.id]
  }

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_cidr_block]
  }

  tags = {
    Name = "${var.environment}_efs_security_group"
    env  = "${var.environment}"
  }
}
