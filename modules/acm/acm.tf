

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.domain_alt_name
  validation_method         = "DNS"

  tags = {
    Name = "${var.environment}_cert"
    env  = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

