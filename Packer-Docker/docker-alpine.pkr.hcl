packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "alpine" {
  image  = "alpine:latest"
  commit = true
}

build {
  name = "alpine"
  sources = [
    "source.docker.alpine"
  ]
}
