output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "The OIDC provider ARN for the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "The OIDC provider URL for the EKS cluster."
  value       = module.eks.cluster_oidc_issuer_url
}