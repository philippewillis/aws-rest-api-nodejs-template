variable "APP_NAME" {}
variable "env_tag" {}
variable "hosted_zone_name" {}
variable "JWT_SECRET" {}

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
  bucket_name  = "my-awesome-api-${var.APP_NAME}${var.domain_suffix}"
  domain_name  = "${var.APP_NAME}${var.domain_suffix}.${var.hosted_zone_name}"
}
