resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    ManagedBy   = "Terraform"
    Environment = "Test"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

