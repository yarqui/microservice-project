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