data "archive_file" "create_zip" {
  type        = "zip"
  source_dir  = "${path.module}/create1.zip"
  output_path = "${path.module}/lambda_function.zip"
}

locals {
  name_prefix = "group3"
}

data "aws_dynamodb_table" "table" {
  name = "group3-shorturl"
}

resource "aws_lambda_function" "http_api_lambda" {
  filename         = data.archive_file.create_zip.output_path
  function_name    = "${local.name_prefix}-cocaching16-api"
  description      = "Lambda function to write to dynamodb"
  runtime          = "python3.13"
  handler          = "create_url_lambda.lambda_handler"
  source_code_hash = data.archive_file.create_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {} # todo: fill with apporpriate value
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.name_prefix}-cocaching16-api-executionrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_role" {
  name = "group3-cocaching16-api-ddbaccess"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem"
            ],
            "Resource": "${data.aws_dynamodb_table.table.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_role.arn
}

provider "aws" {
  region = "us-east-1" # to configure
}