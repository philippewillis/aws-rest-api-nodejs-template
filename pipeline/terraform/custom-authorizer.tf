# =========================
# Lambda Custom Authorizer
# =========================

# Custom Authorizer - Source
data "archive_file" "custom_authorizer_source" {
  type        = "zip"
  source_dir  = "../../build-authorizer"
  output_path = "../../dist/${path.module}/custom-authorizer-source.zip"
}

resource "aws_s3_object" "custom_authorizer_source" {
  bucket = aws_s3_bucket.rest_api_source.id
  key    = "custom-authorizer-source.zip"
  source = data.archive_file.custom_authorizer_source.output_path
  etag   = filemd5(data.archive_file.custom_authorizer_source.output_path)
}

# Custom Authorizer - Lambda Function
resource "aws_lambda_function" "custom_authorizer" {
  function_name = "${local.project_name}-custom-authorizer"

  s3_bucket = aws_s3_bucket.rest_api_source.id
  s3_key    = aws_s3_object.custom_authorizer_source.key

  runtime          = "nodejs20.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.custom_authorizer_source.output_base64sha256

  timeout = 12
  role    = aws_iam_role.custom_authorizer_execution_role.arn

  environment {
    variables = {
      eng_tag              = var.env_tag
      type                 = "api gateway authorizer"
      JWT_SECRET           = var.JWT_SECRET
      JWT_TOKEN_EXPIRATION = var.JWT_TOKEN_EXPIRATION
    }
  }
}

resource "aws_iam_role" "custom_authorizer_execution_role" {
  name = "${local.project_name}-custom-authorizer-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "custom_authorizer_policy" {
  name = "${local.project_name}-custom-authorizer-policy"
  role = aws_iam_role.custom_authorizer_execution_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Custom Authorizer - CloudWatch Logs
resource "aws_cloudwatch_log_group" "custom_authorizer" {
  name              = "/aws/lambda/${aws_lambda_function.custom_authorizer.function_name}"
  retention_in_days = 30
}


















# Custom Authorizer - API Gateway Authorizer, Role, Policy
resource "aws_api_gateway_authorizer" "custom_authorizer" {
  name                   = "${local.project_name}-custom-authorizer"
  type                   = "TOKEN"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_lambda_function.custom_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}















resource "aws_iam_role" "invocation_role" {
  name = "${local.project_name}-api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "apigateway.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "${local.project_name}-invocation-policy"
  role = aws_iam_role.invocation_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "lambda:InvokeFunction",
        "Effect" : "Allow",
        "Resource" : aws_lambda_function.custom_authorizer.arn
      }
    ]
  })
}
