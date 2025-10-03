terraform {
  backend "s3" {
    bucket         = "yar-lesson-7-tfstate-8921"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}