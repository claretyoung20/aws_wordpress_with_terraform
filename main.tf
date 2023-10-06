provider "aws" {
}

# vpc
resource "aws_vpc" "dev-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
    env  = "dev"
  }
}

# interget gateway
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
    env  = "dev"
  }
}

# public subnet in AZ 1
resource "aws_subnet" "dev-public-subnet-AZ1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-AZ1"
    env  = "dev"
  }
}

# public subnet in AZ 2
resource "aws_subnet" "dev-public-subnet-AZ2" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet-AZ2"
    env  = "dev"
  }
}

# Route table
resource "aws_route_table" "dev-public-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-route-table"
    env  = "dev"
  }
}

# associate route table to public subnet to give it internet access
resource "aws_route_table_association" "dev-route-table-association-AZ1" {
  subnet_id      = aws_subnet.dev-public-subnet-AZ1.id
  route_table_id = aws_route_table.dev-public-route-table.id
}

resource "aws_route_table_association" "dev-route-table-association-AZ2" {
  subnet_id      = aws_subnet.dev-public-subnet-AZ2.id
  route_table_id = aws_route_table.dev-public-route-table.id
}

# private subnets in AZ 1
resource "aws_subnet" "dev-private-app-subnet-AZ1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "dev-private-app-subnet-AZ1"
    env  = "dev"
  }
}

resource "aws_subnet" "dev-private-data-subnet-AZ1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "dev-private-data-subnet-AZ1"
    env  = "dev"
  }
}

# private subnets in AZ 2
resource "aws_subnet" "dev-private-app-subnet-AZ2" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "dev-private-app-subnet-AZ2"
    env  = "dev"
  }
}

resource "aws_subnet" "dev-private-data-subnet-AZ2" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "dev-private-data-subnet-AZ2"
    env  = "dev"
  }
}

# elastic ips for the natgateway
resource "aws_eip" "dev-nat_gateway_eip-AZ1" {
  domain = "vpc"

  tags = {
    Name = "dev-nat_gateway_eip-AZ1"
    env  = "dev"
  }
}

resource "aws_eip" "dev-nat_gateway_eip-AZ2" {
  domain = "vpc"

  tags = {
    Name = "dev-nat_gateway_eip-AZ2"
    env  = "dev"
  }
}

# create nat gateways in the 2 public subnet to give internet access to the 4 private subnets in 2 AZs
resource "aws_nat_gateway" "dev-nat-gateway-AZ1" {
  allocation_id     = aws_eip.dev-nat_gateway_eip-AZ1.id
  subnet_id         = aws_subnet.dev-public-subnet-AZ1.id
  connectivity_type = "public"

  tags = {
    Name = "dev-nat-gateway-AZ1"
    env  = "dev"
  }

}

resource "aws_nat_gateway" "dev-nat-gateway-AZ2" {
  allocation_id     = aws_eip.dev-nat_gateway_eip-AZ2.id
  subnet_id         = aws_subnet.dev-public-subnet-AZ2.id
  connectivity_type = "public"

  tags = {
    Name = "dev-nat-gateway-AZ2"
    env  = "dev"
  }

}

# create new private route table to route traffic to private subnets through nat gateway
# Route table AZ1
resource "aws_route_table" "dev-private-route-table-AZ1" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-nat-gateway-AZ1.id
  }

  tags = {
    Name = "dev-private-route-table-AZ1"
    env  = "dev"
  }
}


# Route table AZ2
resource "aws_route_table" "dev-private-route-table-AZ2" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-nat-gateway-AZ2.id
  }

  tags = {
    Name = "dev-private-route-table-AZ2"
    env  = "dev"
  }
}

# associate route table to private subnet to give it internet access
## AZ1
### app
resource "aws_route_table_association" "dev-private-route-table-association-app-AZ1" {
  subnet_id      = aws_subnet.dev-private-app-subnet-AZ1.id
  route_table_id = aws_route_table.dev-private-route-table-AZ1.id
}
### data
resource "aws_route_table_association" "dev-private-route-table-association-data-AZ1" {
  subnet_id      = aws_subnet.dev-private-data-subnet-AZ1.id
  route_table_id = aws_route_table.dev-private-route-table-AZ1.id
}

## AZ2
### app
resource "aws_route_table_association" "dev-private-route-table-association-app-AZ2" {
  subnet_id      = aws_subnet.dev-private-app-subnet-AZ2.id
  route_table_id = aws_route_table.dev-private-route-table-AZ2.id
}

## AZ2
### data
resource "aws_route_table_association" "dev-private-route-table-association-data-AZ2" {
  subnet_id      = aws_subnet.dev-private-data-subnet-AZ2.id
  route_table_id = aws_route_table.dev-private-route-table-AZ2.id
}


# Security groups
# Security Group 1: ALB Security Group
resource "aws_security_group" "dev-alb_security_group" {
  name        = "ALBSecurityGroup"
  description = "Security group for Application Load Balancer (ALB)"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-alb_security_group"
    env  = "dev"
  }

}

# Security Group 2: SSH Security Group
resource "aws_security_group" "dev-ssh_security_group" {
  name        = "SSHSecurityGroup"
  description = "Security group for SSH access"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.42.105.138/32"] # Replace with your IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "dev-ssh_security_group"
    env  = "dev"
  }

}

# Security Group 3: Webserver Security Group
resource "aws_security_group" "dev-webserver_security_group" {
  name        = "WebserverSecurityGroup"
  description = "Security group for webservers"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-alb_security_group.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-alb_security_group.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-ssh_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "dev_webserver_security_group"
    env  = "dev"
  }
}

# Security Group 4: Database Security Group
resource "aws_security_group" "dev_database_security_group" {
  name        = "DatabaseSecurityGroup"
  description = "Security group for database access"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-webserver_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "dev_database_security_group"
    env  = "dev"
  }
}

# Security Group 5: EFS Security Group
resource "aws_security_group" "dev-efs_security_group" {
  name        = "EFSSecurityGroup"
  description = "Security group for Amazon EFS"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.dev-webserver_security_group.id]
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
    security_groups = [aws_security_group.dev-ssh_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-efs_security_group"
    env  = "dev"
  }
}

# RDS MYSQL

# subnet group
resource "aws_db_subnet_group" "dev_db_subnet_group" {
  name        = "dev_db_subnet_group"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.dev-private-data-subnet-AZ1.id, aws_subnet.dev-private-data-subnet-AZ2.id]

  tags = {
    Name = "dev_db_subnet_group"
    env  = "env"
  }
}

resource "aws_db_instance" "dev_database" {
  db_name                 = "<UPDATE_WITH_YOUR_DB_NAME>"
  engine                  = "mysql"
  storage_type            = "gp2"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  username                = "<UPDATE_WITH_YOUR_USERNAME>"
  password                = "<UPDATE_WITH_YOUR_PASSWORD>"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az                = false
  availability_zone       = "eu-west-1a"

  #   Enable storage autoscaling
  allocated_storage     = 20
  max_allocated_storage = 1000

  vpc_security_group_ids = [aws_security_group.dev_database_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.dev_db_subnet_group.name


  tags = {
    Name = "dev_database"
    env  = "env"
  }
}



# EFS
resource "aws_efs_file_system" "dev-efs" {
  creation_token   = "development"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "dev-efs"
    env  = "dev"
  }
}

#  back up policy
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.dev-efs.id

  backup_policy {
    status = "ENABLED"
  }
}

# Network access and Mount targets
resource "aws_efs_mount_target" "dev_efs_mount_target_AZ1" {
  file_system_id  = aws_efs_file_system.dev-efs.id
  subnet_id       = aws_subnet.dev-private-data-subnet-AZ1.id
  security_groups = [aws_security_group.dev-efs_security_group.id]
}

resource "aws_efs_mount_target" "dev_efs_mount_target_AZ2" {
  file_system_id  = aws_efs_file_system.dev-efs.id
  subnet_id       = aws_subnet.dev-private-data-subnet-AZ2.id
  security_groups = [aws_security_group.dev-efs_security_group.id]
}

# key pair for ec2
resource "aws_key_pair" "dev-ssh-key-pair" {
  key_name   = "dev-ssh-key-pair"
  public_key = file("<UPDATE_WITH_YOUR_SSH_KEY_PATH>")

  tags = {
    Name = "dev-ssh-key-pair"
    env  = "dev"
  }
}

# ami-0f3164307ee5d695a (64-bit (x86)) / ami-01dcd5a6deeb2e880 (64-bit (Arm))

# ec2
# resource "aws_instance" "dev-web-server-public" {
#   ami           = "<UPDATE_WITH_YOUR_AMI>"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.dev-public-subnet-AZ1.id
#   key_name      = aws_key_pair.dev-ssh-key-pair.key_name
#   security_groups = [aws_security_group.dev-ssh_security_group.id, aws_security_group.dev-alb_security_group.id,
#   aws_security_group.dev-webserver_security_group.id]
#   user_data = <<-EOF
#     #!/bin/bash
#     echo "<uPDATE_EFS_DNS>:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab
#     mount -a
#     chown apache:apache -R /var/www/html
#     sudo service httpd restart
#   EOF


#   tags = {
#     Name = "dev-web-server-public"
#     env  = "dev"
#   }
# }


# ALB

# Launch template
resource "aws_launch_template" "dev_template" {
  name_prefix            = "dev-template"
  image_id               = "<UPDATE_WITH_YOUR_CUSTOM_AMI"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.dev-ssh-key-pair.key_name
  vpc_security_group_ids = [aws_security_group.dev-webserver_security_group.id]


  user_data = filebase64("${path.module}/launch.sh")
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "dev_template"
    }
  }
}

# Instance Target Group
resource "aws_lb_target_group" "dev_lb_target_group" {
  name     = "dev-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev-vpc.id
  health_check {
    enabled             = true
    interval            = 30             # Interval between health checks (in seconds)
    path                = "/"            # The path to the health check endpoint
    port                = "traffic-port" # Use "traffic-port" to match the port defined above
    protocol            = "HTTP"
    timeout             = 5 # Timeout for each health check (in seconds)
    healthy_threshold   = 2 # Number of consecutive successful health checks required
    unhealthy_threshold = 2 # Number of consecutive failed health checks required
    matcher             = "200,301,302"
  }
}

# load balancer
resource "aws_lb" "dev_alb" {
  name                       = "dev-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.dev-public-subnet-AZ1.id, aws_subnet.dev-public-subnet-AZ2.id]
  enable_deletion_protection = false
  enable_http2               = true
  security_groups            = [aws_security_group.dev-alb_security_group.id]
}


# Attach the target group to the ALB
resource "aws_lb_listener" "dev_lb_listener" {
  load_balancer_arn = aws_lb.dev_alb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.dev_lb_target_group.arn
  # }

  # UPDATE HTTP TO REDURECT TO HTTPS
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}


resource "aws_autoscaling_group" "dev-asg" {
  name                = "dev-asg"
  vpc_zone_identifier = [aws_subnet.dev-private-app-subnet-AZ1.id, aws_subnet.dev-private-app-subnet-AZ2.id]


  # Use the launch template
  launch_template {
    id      = aws_launch_template.dev_template.id
    version = "$Default"
  }

  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.dev_lb_target_group.arn]
}

# Create a Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "dev_autoscaling_policy" {
  name        = "dev_autoscaling_policy"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70 # Target CPU utilization
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    disable_scale_in = false # Allow scale in if needed
  }

  autoscaling_group_name = aws_autoscaling_group.dev-asg.name
}

resource "aws_autoscaling_attachment" "dev_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.dev-asg.name
  lb_target_group_arn    = aws_lb_target_group.dev_lb_target_group.arn
}


# Route 53

resource "aws_route53_zone" "dev-hosted-zone" {
  name = "<UPDATE_YOUR_DOMAIN>"
}

resource "aws_route53_record" "dev-A-record" {
  zone_id = aws_route53_zone.dev-hosted-zone.zone_id
  name    = "<UPDATE_YOUR_DOMAIN>"
  type    = "A"
  alias {
    name                   = aws_lb.dev_alb.dns_name
    zone_id                = aws_lb.dev_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = "<UPDATE_YOUR_DOMAIN>"
  subject_alternative_names = ["*.<UPDATE_YOUR_DOMAIN>"]
  validation_method         = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dev-acm-record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.dev-hosted-zone.zone_id
}

# https lister for our alb
resource "aws_lb_listener" "dev_https_listener" {
  load_balancer_arn = aws_lb.dev_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_lb_target_group.arn
  }

  certificate_arn = aws_acm_certificate.cert.arn
}
