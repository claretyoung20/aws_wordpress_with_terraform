
# key pair for ec2
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "${var.environment}_ssh_key_pair"
  public_key = file(var.public_key)

  tags = {
    Name = "${var.environment}_ssh_key_pair"
    env  = "${var.environment}"
  }
}

# Launch template
resource "aws_launch_template" "template" {
  name_prefix            = "template"
  image_id               = var.custom_ami_id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids = var.web_server_groups


  user_data = filebase64("${path.module}/launch.sh")
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}_template"
    }
  }
}