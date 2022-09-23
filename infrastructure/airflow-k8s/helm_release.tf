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

resource "helm_release" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  namespace  = "airflow"
  version    = "1.6.0"
  wait       = false

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
