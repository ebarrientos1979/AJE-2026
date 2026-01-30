terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Remove unsupported data source
# data "aws_bedrock_knowledge_bases" "aje_kb" {
#   name_contains = "aje"
# }

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-rag-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "bedrock-rag-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "bedrock_rag" {
  filename         = "lambda_function.zip"
  function_name    = "bedrock-rag-agent"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 29
  memory_size     = 512

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      KNOWLEDGE_BASE_ID = "BO2ZUTK4JD"
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "bedrock_api" {
  name        = "bedrock-rag-api"
  description = "API for Bedrock RAG queries"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "query_resource" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  parent_id   = aws_api_gateway_rest_api.bedrock_api.root_resource_id
  path_part   = "query"
}

# API Gateway Method
resource "aws_api_gateway_method" "query_method" {
  rest_api_id   = aws_api_gateway_rest_api.bedrock_api.id
  resource_id   = aws_api_gateway_resource.query_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.query_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.bedrock_rag.invoke_arn
}

# API Gateway Method Response for POST
resource "aws_api_gateway_method_response" "query_response" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.query_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# API Gateway Integration Response for POST
resource "aws_api_gateway_integration_response" "query_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.query_method.http_method
  status_code = aws_api_gateway_method_response.query_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bedrock_rag.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.bedrock_api.execution_arn}/*/*"
}

# CORS Method
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.bedrock_api.id
  resource_id   = aws_api_gateway_resource.query_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS Integration
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.options_method.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Method Response
resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# CORS Integration Response
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id
  resource_id = aws_api_gateway_resource.query_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.bedrock_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.bedrock_api.id
  stage_name    = "prod"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "bedrock_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.bedrock_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.query_resource.id,
      aws_api_gateway_method.query_method.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
