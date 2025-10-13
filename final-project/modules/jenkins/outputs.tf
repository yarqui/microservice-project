output "jenkins_release_name" {
  description = "The name of the Jenkins Helm release."
  value       = helm_release.jenkins.name
}

output "jenkins_namespace" {
  description = "The namespace where Jenkins is deployed."
  value       = helm_release.jenkins.namespace
}