


# 1. IAM Role for Lambda (Trust Policy)
resource "aws_iam_role" "lambda_shortid_role" {
  name = "group3-coaching-16-lambda-role-shortid"

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


# 3. Attach Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_shortid_policy_attach" {
  role       = aws_iam_role.lambda_shortid_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Attach AWSLambdaBasicExecutionRole AWS Managed Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_shortid_basic_execution" {
  role       = aws_iam_role.lambda_shortid_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach AWSXrayWriteOnlyAccess AWS Managed Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_shortid_xray_access" {
  role       = aws_iam_role.lambda_shortid_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSXrayWriteOnlyAccess"
}

# 4. Package Lambda Code (Generates a zip from a local file)
data "archive_file" "shortid_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-fun-shortid.py" # Path to your lambda function file
  output_path = "${path.module}/lambda_shortid_function.zip"
}

# 5. Lambda Function
resource "aws_lambda_function" "shortid_lambda" {
  filename         = data.archive_file.shortid_lambda_zip.output_path
  function_name    = "shortid_function"
  role             = aws_iam_role.lambda_shortid_role.arn
  handler          = "lambda_shortid_function.lambda_handler" # Filename.exported_function
  runtime          = "python3.13"     # Updated to latest supported runtime
  source_code_hash = data.archive_file.shortid_lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.coaching_table.name
    }
  }
}


