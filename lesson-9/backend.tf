terraform {
  backend "s3" {
    bucket         = "yar-tfstate-8921"
    key            = "lesson-9/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}