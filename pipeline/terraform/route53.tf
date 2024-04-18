
data "aws_route53_zone" "base" {
  name         = "${var.hosted_zone_name}."
  private_zone = false
}

resource "aws_route53_record" "domain" {
  name    = local.domain_name
  zone_id = data.aws_route53_zone.base.zone_id
  type    = "A"
  alias {
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
    evaluate_target_health = true
  }
}
