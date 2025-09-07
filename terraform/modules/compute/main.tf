# IAM roles & permissions
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bkr-lambda-base-role" {
  name = "${var.project_prefix}-${var.environment}-lambda-base-role"

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

# Role for data ingestion Lambda
resource "aws_iam_role" "bkr-data-ingestion-role" {
  name = "${var.project_prefix}-${var.environment}-data-ingestion-role"

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

# Role for recommendation Lambda
resource "aws_iam_role" "bkr-reco-role" {
  name = "${var.project_prefix}-${var.environment}-reco-role"

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

# Policy for data ingestion Lambda
resource "aws_iam_policy" "bkr-data-ingestion-policy" {
  name = "${var.project_prefix}-${var.environment}-data-ingestion-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.hotels}",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.user_interactions}"
        ]
      },
      {
        Action = [
          "s3:ListBucket"
        ],
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_names.datasets}"
      },
      {
        Action = [
          "s3:GetObject"
        ],
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_names.datasets}/*"
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Effect   = "Allow"
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Policy for recommendation Lambda
resource "aws_iam_policy" "bkr-reco-policy" {
  name = "${var.project_prefix}-${var.environment}-reco-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_names.hotels}"
        ]
      },
      {
        Action = [
          "kms:Decrypt"
        ],
        Effect   = "Allow"
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Attach policies to data ingestion role
resource "aws_iam_role_policy_attachment" "bkr-data-ingestion-policy" {
  role       = aws_iam_role.bkr-data-ingestion-role.name
  policy_arn = aws_iam_policy.bkr-data-ingestion-policy.arn
}

resource "aws_iam_role_policy_attachment" "bkr-data-ingestion-basic-execution" {
  role       = aws_iam_role.bkr-data-ingestion-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach policies to recommendation role
resource "aws_iam_role_policy_attachment" "bkr-reco-policy" {
  role       = aws_iam_role.bkr-reco-role.name
  policy_arn = aws_iam_policy.bkr-reco-policy.arn
}

resource "aws_iam_role_policy_attachment" "bkr-reco-basic-execution" {
  role       = aws_iam_role.bkr-reco-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach basic execution to base role (for router)
resource "aws_iam_role_policy_attachment" "bkr-base-basic-execution" {
  role       = aws_iam_role.bkr-lambda-base-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function Router
data "archive_file" "bkr-router-lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/router"
  output_path = "${path.module}/router.zip"
}

resource "aws_lambda_function" "bkr-router" {
  filename         = data.archive_file.bkr-router-lambda.output_path
  function_name    = "${var.project_prefix}-${var.environment}-router"
  role             = aws_iam_role.bkr-lambda-base-role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  source_code_hash = data.archive_file.bkr-router-lambda.output_base64sha256

  environment {
    variables = {
      HOTELS_TABLE            = var.dynamodb_table_names.hotels
      USER_INTERACTIONS_TABLE = var.dynamodb_table_names.user_interactions
      EXPERIMENT_CONFIG_TABLE = var.dynamodb_table_names.experiment_config
    }
  }

  tags = var.tags
}

# Lambda Function Data Ingestion
data "archive_file" "bkr-data-ingestion-lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/data-ingestion"
  output_path = "${path.module}/data-ingestion.zip"
}

resource "aws_lambda_function" "bkr-data-ingestion" {
  filename      = data.archive_file.bkr-data-ingestion-lambda.output_path
  function_name = "${var.project_prefix}-${var.environment}-data-ingestion"
  role          = aws_iam_role.bkr-data-ingestion-role.arn
  handler       = "handler.lambda_handler"
  timeout       = 60
  runtime       = "python3.11"

  source_code_hash = data.archive_file.bkr-data-ingestion-lambda.output_base64sha256

  environment {
    variables = {
      DATASETS_BUCKET         = var.s3_bucket_names.datasets
      ARTEFACTS_BUCKET        = var.s3_bucket_names.artefacts
      HOTELS_TABLE            = var.dynamodb_table_names.hotels
      USER_INTERACTIONS_TABLE = var.dynamodb_table_names.user_interactions
      EXPERIMENT_CONFIG_TABLE = var.dynamodb_table_names.experiment_config
    }
  }

  tags = var.tags
}

# Lambda Function Recommendation v1
data "archive_file" "bkr-reco-v1-lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/reco_v1"
  output_path = "${path.module}/reco_v1.zip"
}

resource "aws_lambda_function" "bkr-reco-v1" {
  filename      = data.archive_file.bkr-reco-v1-lambda.output_path
  function_name = "${var.project_prefix}-${var.environment}-reco-v1"
  role          = aws_iam_role.bkr-reco-role.arn
  handler       = "handler.lambda_handler"
  timeout       = 60
  runtime       = "python3.11"

  source_code_hash = data.archive_file.bkr-reco-v1-lambda.output_base64sha256

  environment {
    variables = {
      HOTELS_TABLE = var.dynamodb_table_names.hotels
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

resource "aws_api_gateway_method" "bkr-health-options-method" {
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id   = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bkr-health-options" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-options-method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "bkr-health-options-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-options-method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "bkr-health-options-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-options-method.http_method
  status_code = aws_api_gateway_method_response.bkr-health-options-response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration" "bkr-lambda-health" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-get-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bkr-router.invoke_arn
}

resource "aws_lambda_permission" "bkr-router-api-gw-allow" {
  function_name = aws_lambda_function.bkr-router.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.bkr-rest-api.execution_arn}/*/*"

}

resource "aws_api_gateway_resource" "bkr-reco-v1-endpoint" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  parent_id   = aws_api_gateway_rest_api.bkr-rest-api.root_resource_id
  path_part   = "recommendations"
}

resource "aws_api_gateway_method" "bkr-reco-v1-get-method" {
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id   = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "bkr-reco-v1-options-method" {
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id   = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bkr-reco-v1-options" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method = aws_api_gateway_method.bkr-reco-v1-options-method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "bkr-reco-v1-options-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method = aws_api_gateway_method.bkr-reco-v1-options-method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "bkr-reco-v1-options-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method = aws_api_gateway_method.bkr-reco-v1-options-method.http_method
  status_code = aws_api_gateway_method_response.bkr-reco-v1-options-response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_lambda_permission" "bkr-reco-v1-api-gw-allow" {
  function_name = aws_lambda_function.bkr-reco-v1.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.bkr-rest-api.execution_arn}/*/*"

}

resource "aws_api_gateway_integration" "bkr-lambda-reco-v1" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method = aws_api_gateway_method.bkr-reco-v1-get-method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bkr-reco-v1.invoke_arn
}

resource "aws_api_gateway_method_response" "bkr-reco-v1-get-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-reco-v1-endpoint.id
  http_method = aws_api_gateway_method.bkr-reco-v1-get-method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "bkr-health-get-response" {
  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id
  resource_id = aws_api_gateway_resource.bkr-health-endpoint.id
  http_method = aws_api_gateway_method.bkr-health-get-method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_deployment" "bkr-api-gw-deployment" {
  depends_on = [
    aws_api_gateway_method.bkr-health-get-method,
    aws_api_gateway_integration.bkr-lambda-health,
    aws_api_gateway_method.bkr-health-options-method,
    aws_api_gateway_integration.bkr-health-options,
    aws_api_gateway_method.bkr-reco-v1-get-method,
    aws_api_gateway_integration.bkr-lambda-reco-v1,
    aws_api_gateway_method.bkr-reco-v1-options-method,
    aws_api_gateway_integration.bkr-reco-v1-options,
    aws_api_gateway_method_response.bkr-reco-v1-get-response,
    aws_api_gateway_method_response.bkr-health-get-response
  ]

  rest_api_id = aws_api_gateway_rest_api.bkr-rest-api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.bkr-health-endpoint.id,
      aws_api_gateway_method.bkr-health-get-method.id,
      aws_api_gateway_integration.bkr-lambda-health.id,
      aws_api_gateway_resource.bkr-reco-v1-endpoint.id,
      aws_api_gateway_method.bkr-reco-v1-get-method.id,
      aws_api_gateway_integration.bkr-lambda-reco-v1.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "bkr-api-stage" {
  deployment_id = aws_api_gateway_deployment.bkr-api-gw-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.bkr-rest-api.id
  stage_name    = var.environment
}
