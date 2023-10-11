
# EFS
resource "aws_efs_file_system" "efs" {
  creation_token   = "development"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.environment}_efs"
    env  = "${var.environment}"
  }
}

#  back up policy
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

# Network access and Mount targets
resource "aws_efs_mount_target" "efs_mount_target_AZ1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_data_subnet_AZ1_id
  security_groups = var.efs_sec_groups 
}

resource "aws_efs_mount_target" "efs_mount_target_AZ2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_data_subnet_AZ2_id
  security_groups = var.efs_sec_groups 
}