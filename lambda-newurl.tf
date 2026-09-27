
# 1. IAM Role for Lambda (Trust Policy)
resource "aws_iam_role" "lambda_newurl_role" {
  name = "group3-coaching-16-lambda-role-newurl"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 2. IAM Policy for DynamoDB and CloudWatch Logs Access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "group3-coaching-16-lambda-dynamodb-policy"
  description = "Provides Lambda permissions to DynamoDB and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = [
          aws_dynamodb_table.coaching_table.arn,
          "${aws_dynamodb_table.coaching_table.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_newurl_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Attach AWSLambdaBasicExecutionRole AWS Managed Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_newurl_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWSXrayWriteOnlyAccess AWS Managed Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_xray_access" {
  role       = aws_iam_role.lambda_newurl_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# 4. Package Lambda Code (Generates a zip from a local file)
data "archive_file" "newurl_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-fun-newurl.py" # Path to your lambda function file
  output_path = "${path.module}/lambda_newurl_function.zip"
}

# 5. Lambda Function
resource "aws_lambda_function" "newurl_lambda" {
  filename         = data.archive_file.newurl_lambda_zip.output_path
  function_name    = "newurl_function"
  role             = aws_iam_role.lambda_newurl_role.arn
  handler          = "lambda_newurl_function.lambda_handler" # Filename.exported_function
  runtime          = "python3.13"     # Updated to latest supported runtime
  source_code_hash = data.archive_file.newurl_lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.coaching_table.name
    }
  }
}

