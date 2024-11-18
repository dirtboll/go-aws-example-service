resource "aws_acm_certificate" "app" {
  domain_name       = var.app_domain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
}