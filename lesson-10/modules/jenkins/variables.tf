variable "cluster_name" {
  description = "Name of Kubernetes cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "github_user" {
  type = string
}

variable "github_pat" {
  type      = string
  sensitive = true
}

variable "github_repo_url" {
  type = string
}

variable "ecr_repo_url" {
  type        = string
  description = "The URL of the ECR repository."
}