
# RDS MYSQL

# subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.environment}_db_subnet_group"
  description = "RDS subnet group"
  subnet_ids  = var.subnet_ids 

  tags = {
    Name = "${var.environment}_db_subnet_group"
    env  = "${var.environment}"
  }
}

resource "aws_db_instance" "database" {
  db_name                 = var.db_name
  engine                  = "mysql"
  storage_type            = "gp2"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  backup_retention_period = 7
  multi_az                = false
  availability_zone       = var.availability_zone

  #   Enable storage autoscaling
  allocated_storage     = 20
  max_allocated_storage = 1000

  vpc_security_group_ids = var.vpc_security_group_ids 
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name


  tags = {
    Name = "${var.environment}_database"
    env  = "${var.environment}"
  }
}

