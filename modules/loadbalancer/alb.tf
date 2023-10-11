
# Instance Target Group
resource "aws_lb_target_group" "lb-target-group" {
  name     = "${var.environment}-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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
resource "aws_lb" "alb" {
  name                       = "${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.alb_subnets
  enable_deletion_protection = false
  enable_http2               = true
  security_groups            = var.alb_sec_group 


  tags = {
    Name = "${var.environment}-alb"
    env  = "${var.environment}"
  }
}


# Attach the target group to the ALB
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.lb_target_group.arn
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


resource "aws_autoscaling_group" "asg" {
  name                = "${var.environment}_asg"
  vpc_zone_identifier = var.vpc_zone_identifiers // 


  # Use the launch template
  launch_template {
    id      = var.launch_template_id // aws_launch_template.template.id
    version = "$Default"
  }

  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 1
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.lb-target-group.arn]
}

# Create a Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "autoscaling_policy" {
  name        = "autoscaling_policy"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 70 # Target CPU utilization
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    disable_scale_in = false # Allow scale in if needed
  }

  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_attachment" "autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.lb-target-group.arn
}

# https lister for our alb
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }

  certificate_arn = var.cert_arn //aws_acm_certificate.cert.arn
}
