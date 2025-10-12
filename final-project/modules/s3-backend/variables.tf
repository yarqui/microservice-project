variable "bucket_name" {
  description = "The name of the S3 bucket to store the Terraform state."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table for state locking."
  type        = string
}