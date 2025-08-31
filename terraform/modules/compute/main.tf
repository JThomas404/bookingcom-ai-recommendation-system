# IAM
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bkr-lambda-role" {
  name = "${var.project_prefix}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "bkr-lambda-dynamodb-policy" {
  name = "${var.project_prefix}-${var.environment}-lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.hotels}",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.user_interactions}",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.experiment_config}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bkr-lambda-dynamodb-policy" {
  role       = aws_iam_role.bkr-lambda-role.name
  policy_arn = aws_iam_policy.bkr-lambda-dynamodb-policy.arn
}

resource "aws_iam_role_policy_attachment" "bkr-lambda-basic-execution" {
  role       = aws_iam_role.bkr-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
data "archive_file" "bkr-lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/router"
  output_path = "${path.module}/router.zip"
}

resource "aws_lambda_function" "bkr-router" {
  filename         = data.archive_file.bkr-lambda.output_path
  function_name    = "${var.project_prefix}-${var.environment}-router"
  role             = aws_iam_role.bkr-lambda-role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.bkr-lambda.output_base64sha256

  environment {
    variables = {
      HOTELS_TABLE            = var.dynamodb_table_names.hotels
      USER_INTERACTIONS_TABLE = var.dynamodb_table_names.user_interactions
      EXPERIMENT_CONFIG_TABLE = var.dynamodb_table_names.experiment_config
    }
  }

  tags = var.tags
}

# API Gateway Methods & Integration
resource "aws_api_gateway_rest_api" "bkr-rest-api" {
  name = "${var.project_prefix}-${var.environment}-api"

  tags = var.tags
}

resource "aws_api_gateway_resource" "bkr-health-endpoint" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  parent_id   = aws_api_gateway_rest_api.bkr-rest-api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "bkr-health-get-method" {
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id   = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bkr-lambda-health" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-get-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bkr-router.invoke_arn
}

resource "aws_lambda_permission" "bkr-api-gw-allow" {
  function_name = aws_lambda_function.bkr-router.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.bkr-rest-api.execution_arn}/*/*"

}

resource "aws_api_gateway_deployment" "bkr-api-gw-deployment" {
  depends_on = [
    aws_api_gateway_method.bkr-health-get-method,
    aws_api_gateway_integration.bkr-lambda-health,
  ]

  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
}

resource "aws_api_gateway_stage" "bkr-api-stage" {
  deployment_id = aws_api_gateway_deployment.bkr-api-gw-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  stage_name    = var.environment
}
