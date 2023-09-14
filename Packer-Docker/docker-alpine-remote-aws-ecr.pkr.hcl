#export PACKER_PLUGIN_PATH=./plugins
packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "alpine" {
  image  = "alpine:latest"
  commit = true
}

build {
  name    = "golden-docker-alpine"
  sources = [
    "source.docker.alpine"
  ]
post-processors {
  post-processor "docker-tag" {
    repository = "983083522813.dkr.ecr.us-east-1.amazonaws.com/bbarkhouse-docker-alpine"
    tags       = ["0.2", "latest"]
  }

  post-processor "docker-push" {
    ecr_login = true
    #export AWS creds as env variables
    #aws_access_key = "YOUR KEY HERE"
    #aws_secret_key = "YOUR SECRET KEY HERE"
    login_server = "983083522813.dkr.ecr.us-east-1.amazonaws.com/bbarkhouse-docker-alpine"
  }
}
}

