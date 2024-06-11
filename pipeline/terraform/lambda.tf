resource "aws_lambda_function" "rest_api" {
  function_name = local.project_name

  s3_bucket = aws_s3_bucket.rest_api_source.id
  s3_key    = aws_s3_object.rest_api_source.key

  runtime          = "nodejs20.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.rest_api_source.output_base64sha256

  role    = aws_iam_role.lambda_exec_rest_api.arn
  timeout = 12

  environment {
    variables = {
      eng_tag = var.env_tag
    }
  }

  tags = {
    Name        = var.APP_NAME
    Environment = terraform.workspace
    Version     = var.APP_VERSION
  }
}

resource "aws_cloudwatch_log_group" "rest_api" {
  name              = "/aws/lambda/${aws_lambda_function.rest_api.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec_rest_api" {
  name = "${local.project_name}_serverless_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_exec" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec_rest_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_rest_api" {
  role       = aws_iam_role.lambda_exec_rest_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
