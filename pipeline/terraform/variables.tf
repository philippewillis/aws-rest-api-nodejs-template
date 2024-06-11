variable "APP_NAME" {}
variable "APP_VERSION" {}
variable "HOSTED_ZONE_NAME" {}
variable "JWT_SECRET" {}
variable "JWT_TOKEN_EXPIRATION" {}

variable "env_tag" {}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "api_version" {
  type    = string
  default = "v1"
}

variable "domain_suffix" {
  type    = string
  default = ""
}



locals {
  project_name = "${var.APP_NAME}${var.domain_suffix}"
  bucket_name  = "${var.APP_NAME}${var.domain_suffix}-rest-api"
  domain_name  = "${var.APP_NAME}${var.domain_suffix}.${var.HOSTED_ZONE_NAME}"
}
