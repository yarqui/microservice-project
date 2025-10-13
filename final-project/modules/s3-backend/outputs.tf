output "s3_bucket_id" {
    description = "The ID (name) of the S3 bucket."
    value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
    description = "The name of the DynamoDB table."
    value       = aws_dynamodb_table.terraform_locks.name
}