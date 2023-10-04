terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
  cloud {
    organization = "bbarkhouse-training"
    ## Required for Terraform Enterprise; Defaults to app.terraform.io for Terraform Cloud
    hostname = "app.terraform.io"

    workspaces {
      tags = ["aws-ecs"]
    }
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}