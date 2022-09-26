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
  # repository = "https://charts.bitnami.com/bitnami"
  # chart      = "airflow"
  # name       = "airflow"
  # version    = "13.1.6"
  # namespace  = "airflow"
  # wait       = false

  # values = [
  #   "${file("airflow-values-bitnami.yaml")}"
  # ]

  # repository        = "https://airflow-helm.github.io/charts"
  # chart             = "airflow"
  # name              = "airflow"
  # version           = "8.6.1"
  # namespace         = "airflow"
  # wait              = false
  # dependency_update = true

  # values = [
  #   "${file("airflow-values-community.yaml")}"
  # ]

  repository        = "https://airflow.apache.org/"
  chart             = "airflow"
  name              = "airflow"
  version           = "1.6.0"
  namespace         = "airflow"
  wait              = false
  dependency_update = true

  values = [
    "${file("airflow-values-official.yaml")}"
  ]

}

# resource "helm_release" "keda" {
#   repository        = "https://kedacore.github.io/charts"
#   chart             = "keda"
#   name              = "keda"
#   version           = "v2.0.0"
#   namespace         = "keda"
#   wait              = false
#   dependency_update = true

# }