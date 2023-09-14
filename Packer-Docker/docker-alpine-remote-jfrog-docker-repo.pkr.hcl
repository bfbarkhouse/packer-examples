#export PACKER_PLUGIN_PATH=./plugins
#docker login
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
        repository =  "3.234.144.153:8082/artifactory/bbarkhouse-artifactory-generic-repo-01/bbarkhouse-docker-alpine"
        tags = ["0.1", "latest"]
      }
    post-processor "docker-push" {}
}
}

