provider "aws" {
  region = "us-east-1"
  alias  = "certificates"
}

provider "aws" {
  region = var.region
  alias  = "dns"
}

module "cert" {
  source = "github.com/azavea/terraform-aws-acm-certificate?ref=4.0.0"

  providers = {
    aws.acm_account     = aws.certificates
    aws.route53_account = aws.dns
  }

  domain_name                       = local.domain_name
  hosted_zone_id                    = data.aws_route53_zone.base.zone_id
  validation_record_ttl             = "60"
  allow_validation_record_overwrite = true
}
