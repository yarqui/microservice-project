terraform {
  backend "s3" {
    bucket         = "yar-tfstate-8921"
    key            = "final-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}