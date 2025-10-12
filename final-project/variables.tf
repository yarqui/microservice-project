variable "github_user" {
  type        = string
  description = "GitHub username for Jenkins."
}

variable "github_pat" {
  type        = string
  description = "GitHub PAT for Jenkins to access the repository."
  sensitive   = true
}

variable "github_repo_url" {
  type        = string
  description = "URL of the Git repository for the Jenkins seed job."
}

variable "db_password" {
  description = "Password for the RDS/Aurora database master user."
  type        = string
  sensitive   = true
}

variable "deploy_aurora_database" {
  description = "If true, deploys the Aurora database. If false, deploys the standard RDS database."
  type        = bool
  default     = false # Deploy RDS by default
}