output "s3_backend_bucket_id" {
  description = "The ID of the S3 bucket for the backend."
  value       = module.s3_backend.s3_bucket_id
}

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = module.ecr.repository_url
}