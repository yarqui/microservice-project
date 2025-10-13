variable "name" {
  description = "Helm-release name for Argo CD"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD chart version"
  type        = string
  default     = "5.46.4"
}

variable "github_repo_url" {
  description = "The URL of the Git repository Argo CD will monitor."
  type        = string
}

variable "github_user" {
  description = "Your GitHub username."
  type        = string
}

variable "github_pat" {
  description = "Your GitHub Personal Access Token."
  type        = string
  sensitive   = true
}