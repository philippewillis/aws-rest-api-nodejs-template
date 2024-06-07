# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api
# Terraform `Amazon API Gateway Version 1` used for AWS REST APIs. 
# Terraform `Amazon API Gateway Version 2` used for AWS WebSocket & HTTP APIs

# AWS REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = local.project_name
  description = "REST API service for ${local.project_name}"
}





################################################################################
## Catch all proxy resource (resource/method/integration) all via the Lambda
################################################################################

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"

  # authorization = "NONE"

  authorization = "CUSTOM"                                        #TODO: Add custom-authorizer
  authorizer_id = aws_api_gateway_authorizer.custom_authorizer.id #TODO: Add custom-authorizer
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_method.proxy.resource_id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rest_api.invoke_arn
}

# Allow API Gateway to access the AWS Lambda
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowExecuteFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rest_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}



















resource "aws_iam_role" "apigateway_invocation_role" {
  name = "${local.project_name}-apigateway-invocation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "invoke_lambda_policy" {
  name = "invoke_lambda_policy"
  role = aws_iam_role.apigateway_invocation_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "lambda:InvokeFunction",
        Effect   = "Allow",
        Resource = aws_lambda_function.rest_api.arn
      }
    ]
  })
}










################################################################################
## Deployment parts
################################################################################

# Enables CORS
module "aws_api_gateway_cors_proxy" {
  source          = "./cors"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.proxy.id
}

# Deployment (snapshot of the REST API configurations)
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id
    ]))
  }
}

resource "aws_api_gateway_stage" "api_deployment" {
  stage_name    = var.api_version
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}



################################################################################
## Custom domain name
################################################################################
resource "aws_api_gateway_domain_name" "api" {
  domain_name     = local.domain_name
  certificate_arn = module.cert.arn
}
resource "aws_api_gateway_base_path_mapping" "api_deployment" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_deployment.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}













################################################################################
## CloudWacth
################################################################################
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "${local.project_name}-api-gateway-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Effect = "Allow",
      },
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_cloudwatch" {
  name = "${local.project_name}-api-gateway-cloudwatch"
  role = aws_iam_role.api_gateway_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

# API Gateway logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name = "/aws/apigateway/${aws_api_gateway_rest_api.api.name}"
}
