# --------- Backend --------- 
output "s3_backend_bucket_id" {
  description = "The ID of the S3 bucket for the backend."
  value       = module.s3_backend.s3_bucket_id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = module.s3_backend.dynamodb_table_name
}

# --------- VPC --------- 

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "The availability zones for the VPC." 
  value       = module.vpc.availability_zones
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway."
  value       = module.vpc.internet_gateway_id
}

# --------- ECR --------- 
output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = module.ecr.repository_url
}

# --------- EKS --------- 
output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = module.eks.eks_cluster_endpoint

}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "The ARN of the EKS node role."
  value       = module.eks.eks_node_role_arn
}

