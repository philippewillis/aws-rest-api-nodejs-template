#***********************************************************************************************************************************************************#
#** This certificate needs to be created manually in the AWS Console so that it is available for use by Terraform.                                          #
#** Wanted to avoid having the certificate managed by Terraform because we want to avoid creating/destroying the same certificate over and over again.      #
#***********************************************************************************************************************************************************#


# Define the provider for ACM in us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "certificates"
}

# Data source for ACM certificate in us-east-1
data "aws_acm_certificate" "issued" {
  provider = aws.certificates
  domain   = var.HOSTED_ZONE_NAME
  statuses = ["ISSUED"]
}
