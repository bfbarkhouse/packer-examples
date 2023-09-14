#export PACKER_PLUGIN_PATH=./plugins
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
  changes = [
    "WORKDIR /custom",
  ]
}

build {
  name = "golden-docker-alpine"
  sources = [
    "source.docker.alpine"
  ]
  post-processors {
    #Apply name and tags
    post-processor "docker-tag" {
      repository = "artifactory/bbarkhouse-generic-alpine"
      tags       = ["0.1"]
    }
    #Save container image to file
    post-processor "docker-save" {
      path = "golden-docker-alpine-0_1.tar"
    }
    #Upload to Artifactory
    post-processor "shell-local" {
      inline = ["jf rt u golden-docker-alpine-*.tar bbarkhouse-generic-alpine --recursive=false --url http://3.234.144.153:8082/artifactory/ --user packer --password Packer123"]
    }
  }
}
#You can then download the image from Artifactory and run locally using "docker load --input <path to tar file>"

