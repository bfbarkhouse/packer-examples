# Locate the Packer built image
data "hcp_packer_artifact" "nginx-AWS-ECR" {
  bucket_name   = "nginx-AWS-ECR"
  channel_name  = "latest"
  platform      = "docker"
  region        = "docker"
}
data "aws_ecr_image" "service_image" {
  repository_name = "bbarkhouse-docker-nginx"
  image_digest = data.hcp_packer_artifact.nginx-AWS-ECR.external_identifier
}
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
        }
      }
      spec {
        container {
          image = data.aws_ecr_image.service_image.image_uri
          name  = "nginx"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
