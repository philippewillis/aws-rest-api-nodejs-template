variable "api_id" {
  description = "API identifier"
}

variable "api_resource_id" {
  description = "API resource idenfifier"
}

variable "allow_headers" {
  description = "Allow headers"
  type = list(string)
  default = [ "Authorization", "Content-Type", "X-Amz-Date", "X-Amz-Security-Token", "X-Api-Key" ]
}

variable "allow_methods" {
  description = "Allow methods"
  type = list(string)
  default = [ "OPTIONS", "HEAD", "GET", "POST", "PUT", "PATCH", "DELETE" ]
}

variable "allow_origin" {
  description = "Allow origin"
  type = string
  default = "*"
}

variable "allow_max_age" {
  description = "Allow response caching time"
  type = string
  default = "7200"
}

variable "allow_credentials" {
  description = "Allow credentials"
  default = false
}