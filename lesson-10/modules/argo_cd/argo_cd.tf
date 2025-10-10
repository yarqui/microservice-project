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

  values = [
    templatefile("${path.module}/charts/values.yaml", {
      github_repo_url = var.github_repo_url
      github_user     = var.github_user
      github_pat      = var.github_pat

      db_host     = var.db_host
      db_name     = var.db_name
      db_user     = var.db_user
      db_password = var.db_password
    })
  ]
  
  depends_on = [helm_release.argo_cd]
}