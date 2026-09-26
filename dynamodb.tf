
# 6. Sample DynamoDB Table (for complete dependency references)
resource "aws_dynamodb_table" "coaching_table" {
  name         = "group3-coaching-16-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
