resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

}

resource "helm_release" "argo_apps" {
  name       = "${var.name}-apps"
  chart      = "${path.module}/charts"
  namespace  = var.namespace
  create_namespace = false

  # values = [
  #   templatefile("${path.module}/charts/values.yaml", {
  #     github_repo_url = var.github_repo_url
  #     github_user     = var.github_user
  #     github_pat      = var.github_pat

  #     db_host     = var.db_host
  #     db_name     = var.db_name
  #     db_user     = var.db_user
  #     db_password = var.db_password
  #   })
  # ]
  
  depends_on = [helm_release.argo_cd]
}

resource "kubernetes_manifest" "argo_app_of_apps" {
  manifest = templatefile("${path.module}/charts/templates/application.yaml", {
    # This Values object simulates the Helm .Values object
    Values = {
      applications = [
        {
          name    = "django-app"
          project = "default"
          source = {
            repoURL        = var.github_repo_url
            path           = "lesson-10/charts/django-app"
            targetRevision = "lesson-10"
            helm = {
              valueFiles = ["values.yaml"]
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "production"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
          }
        }
      ]
      # These are the values the template needs
      db_host     = var.db_host
      db_name     = var.db_name
      db_user     = var.db_user
      db_password = var.db_password
    }
  })
  depends_on = [helm_release.argo_cd]
}