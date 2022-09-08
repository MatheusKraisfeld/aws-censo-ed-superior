provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

# resource "helm_release" "kubewatch" {
#   name       = "kubewatch"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "kubewatch"

#   values = [
#     file("${path.module}/kubewatch-values.yaml")
#   ]

#   set_sensitive {
#     name  = "slack.token"
#     value = var.slack_app_token
#   }
# }

resource "helm_release" "airflow" {
  name       = "airflow"
  repository = "https://airflow-helm.github.io/charts"
  chart      = "airflow"
  namespace  = "airflow"

  values = [
    "${file("airflow-values.yaml")}"
  ]

  set_sensitive {
    name  = "controller.adminUser"
    value = var.airflow_admin_user
  }

  set_sensitive {
    name  = "controller.adminPassword"
    value = var.airflow_admin_password
  }

  # set {
  #   name = "controller.replicaCount"
  #   value = "1"
  # }
}
