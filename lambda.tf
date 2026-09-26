resource "lambda_function" "example" {
  function_name = "example_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  filename      = "lambda_function_payload.zip"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      ENV_VAR = "value"
    }
  }
}