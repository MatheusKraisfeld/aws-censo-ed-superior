provider "aws" {
  region = var.region
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-state-741358071637"
    key    = "aws-censo-ed-superior/terraform.tfstate"
    region = "us-east-1"
  }
}

# Retrieve EKS cluster configuration
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }
}

# resource "kubernetes_namespace" "keda" {
#   metadata {
#     name = "keda"
#   }
# }