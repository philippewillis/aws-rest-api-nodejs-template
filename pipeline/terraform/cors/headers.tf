locals {
  headers = {
    "Access-Control-Allow-Headers"      = "'${join(",", var.allow_headers)}'"
    "Access-Control-Allow-Methods"      = "'${join(",", var.allow_methods)}'"
    "Access-Control-Allow-Origin"       = "'${var.allow_origin}'"
    "Access-Control-Max-Age"            = "'${var.allow_max_age}'"
    "Access-Control-Allow- Credentials" = var.allow_credentials ? "'true'" : ""
  }

  header_values = compact(values(local.headers))

  header_names = matchkeys(
    keys(local.headers),
    values(local.headers),
    local.header_values
  )

  parameter_names = formatlist(
    "method.response.header.%s",
    local.header_names
  )
  true_list = split("|",
    replace(
      join("|", local.parameter_names),
      "/[^|]+/",
      true
    )
  )
  integration_response_parameters = zipmap(
    local.parameter_names,
    local.header_values
  )
  method_response_parameters = zipmap(
    local.parameter_names,
    local.true_list
  )
}

